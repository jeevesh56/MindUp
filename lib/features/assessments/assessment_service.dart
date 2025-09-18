import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/firebase_readiness.dart';
import 'models/assessment_question.dart';

class AssessmentService {
  final String _collectionPath;

  AssessmentService({String collectionPath = 'assessment_results'}) : _collectionPath = collectionPath;

  FirebaseFirestore? _dbOrNull() {
    if (!FirebaseReadiness.isInitialized) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? _colOrNull() {
    final db = _dbOrNull();
    return db?.collection(_collectionPath);
  }

  Future<void> saveAssessmentResult(AssessmentResult result, {String? userId}) async {
    final col = _colOrNull();
    if (col == null) return;
    
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

  Stream<List<AssessmentResult>> getRecentResults({int days = 30, String? userId}) {
    final col = _colOrNull();
    if (col == null) return Stream.value(const <AssessmentResult>[]);
    
    final since = DateTime.now().subtract(Duration(days: days));
    Query<Map<String, dynamic>> q = col
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('completedAt', descending: true);
    
    if (userId != null) {
      q = q.where('userId', isEqualTo: userId);
    }
    
    return q.snapshots().map((snap) => snap.docs.map(_resultFromDoc).toList());
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
      recommendations: List<String>.from(data['recommendations'] as List? ?? []),
      completedAt: dt,
    );
  }
}

