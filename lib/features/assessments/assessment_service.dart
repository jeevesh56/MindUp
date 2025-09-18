import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/firebase_readiness.dart';
import 'models/assessment_question.dart';

class AssessmentService {
  final String _collectionPath;

  AssessmentService({String collectionPath = 'assessment_results'})
    : _collectionPath = collectionPath;

  FirebaseFirestore? _dbOrNull() {
    if (!FirebaseReadiness.isInitialized) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? _colOrNull() {
    final db = _dbOrNull();
    return db?.collection(_collectionPath);
  }

  Future<void> saveAssessmentResult(
    AssessmentResult result, {
    String? userId,
  }) async {
    // Save to Firestore when available
    final col = _colOrNull();
    if (col != null) {
      await col.doc(result.id).set({
        'id': result.id,
        'category': result.category,
        'totalScore': result.totalScore,
        'maxScore': result.maxScore,
        'level': result.level,
        'description': result.description,
        'recommendations': result.recommendations,
        'completedAt': Timestamp.fromDate(result.completedAt.toUtc()),
        'userId': userId ?? 'anonymous',
      });
    }

    // Always cache locally so Recent Results can show immediately offline, too
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'assessment_cache_${userId ?? 'anonymous'}';
      final existing = prefs.getStringList(key) ?? <String>[];
      final entry = _serialize(result);
      // Keep only latest 20 results
      final updated = <String>[entry, ...existing];
      if (updated.length > 20) updated.removeRange(20, updated.length);
      await prefs.setStringList(key, updated);
    } catch (_) {
      // Ignore cache failures
    }
  }

  Stream<List<AssessmentResult>> getRecentResults({
    int days = 30,
    String? userId,
  }) {
    final col = _colOrNull();
    final since = DateTime.now().subtract(Duration(days: days));

    if (col == null) {
      // Fallback to local cache when Firebase isn't ready
      return Stream.fromFuture(
        _readLocalCache(userId: userId),
      ).asBroadcastStream();
    }

    Query<Map<String, dynamic>> q = col
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('completedAt', descending: true);
    if (userId != null) {
      q = q.where('userId', isEqualTo: userId);
    }

    // Merge Firestore stream with a one-time local cache emit for fast first paint
    final firestoreStream = q.snapshots().map(
      (snap) => snap.docs.map(_resultFromDoc).toList(),
    );
    final localFirst = Stream.fromFuture(
      _readLocalCache(userId: userId),
    ).asyncExpand(
      (local) => Stream<List<AssessmentResult>>.fromIterable([local]),
    );
    return StreamGroup.merge<List<AssessmentResult>>([
      localFirst,
      firestoreStream,
    ]);
  }

  Future<List<AssessmentResult>> _readLocalCache({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'assessment_cache_${userId ?? 'anonymous'}';
      final raw = prefs.getStringList(key) ?? <String>[];
      final parsed =
          raw.map(_deserialize).whereType<AssessmentResult>().toList();
      // Filter by days (30) just in case
      final since = DateTime.now().subtract(const Duration(days: 30));
      return parsed.where((r) => r.completedAt.isAfter(since)).toList();
    } catch (_) {
      return const <AssessmentResult>[];
    }
  }

  String _serialize(AssessmentResult r) {
    final recs = r.recommendations.join('\u0001');
    return [
      r.id,
      r.category,
      r.totalScore.toString(),
      r.maxScore.toString(),
      r.level,
      r.description.replaceAll('\n', '\\n'),
      recs,
      r.completedAt.toIso8601String(),
    ].join('\u0000');
  }

  AssessmentResult? _deserialize(String s) {
    final parts = s.split('\u0000');
    if (parts.length < 8) return null;
    final recommendations =
        parts[6].isEmpty ? <String>[] : parts[6].split('\u0001');
    return AssessmentResult(
      id: parts[0],
      category: parts[1],
      totalScore: int.tryParse(parts[2]) ?? 0,
      maxScore: int.tryParse(parts[3]) ?? 0,
      level: parts[4],
      description: parts[5].replaceAll('\\n', '\n'),
      recommendations: recommendations,
      completedAt: DateTime.tryParse(parts[7]) ?? DateTime.now(),
    );
  }

  AssessmentResult _resultFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['completedAt'];
    DateTime dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is DateTime) {
      dt = ts;
    } else {
      dt = DateTime.now();
    }

    return AssessmentResult(
      id: data['id'] as String? ?? doc.id,
      category: data['category'] as String? ?? '',
      totalScore: (data['totalScore'] as num?)?.toInt() ?? 0,
      maxScore: (data['maxScore'] as num?)?.toInt() ?? 0,
      level: data['level'] as String? ?? 'Unknown',
      description: data['description'] as String? ?? '',
      recommendations: List<String>.from(
        data['recommendations'] as List? ?? [],
      ),
      completedAt: dt,
    );
  }
}
