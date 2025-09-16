import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/firebase_readiness.dart';
import 'models/mood_entry.dart';

class MoodService {
	final String _collectionPath;

	MoodService({String collectionPath = 'mood_entries'}) : _collectionPath = collectionPath;

	FirebaseFirestore? _dbOrNull() {
		if (!FirebaseReadiness.isInitialized) return null;
		return FirebaseFirestore.instance;
	}

	CollectionReference<Map<String, dynamic>>? _colOrNull() {
		final db = _dbOrNull();
		return db?.collection(_collectionPath);
	}

	Future<void> addMood({required int score, String? note, String? userId}) async {
		final col = _colOrNull();
		if (col == null) return;
		final id = col.doc().id;
		final entry = MoodEntry(id: id, moodScore: score, note: note, createdAt: DateTime.now());
		await col.doc(id).set({
			...entry.toMap(),
			'userId': userId ?? 'anonymous',
		});
	}

	Stream<List<MoodEntry>> streamRecent({int days = 30, String? userId}) {
		final col = _colOrNull();
		if (col == null) return Stream.value(const <MoodEntry>[]);
		final since = DateTime.now().subtract(Duration(days: days));
		Query<Map<String, dynamic>> q = col
			.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
			.orderBy('createdAt');
		if (userId != null) {
			q = q.where('userId', isEqualTo: userId);
		}
		return q.snapshots().map((snap) => snap.docs.map(MoodEntry.fromDoc).toList());
	}
}
