import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/firebase_readiness.dart';
import 'models/forum_post.dart';

class ForumService {
	final String _collection;
	ForumService({String collection = 'forum_posts'}) : _collection = collection;

	// Simple in-memory queue for offline posts
	static final List<ForumPost> _offlineQueue = <ForumPost>[];

	FirebaseFirestore? _dbOrNull() {
		if (!FirebaseReadiness.isInitialized) return null;
		return FirebaseFirestore.instance;
	}

	CollectionReference<Map<String, dynamic>>? _colOrNull() {
		final db = _dbOrNull();
		return db?.collection(_collection);
	}

	Stream<List<ForumPost>> streamRecent() {
		final col = _colOrNull();
		if (col == null) return Stream.value(const <ForumPost>[]);
		return col.orderBy('createdAt', descending: true).limit(100).snapshots().map((s) => s.docs.map(ForumPost.fromDoc).toList());
	}

	Future<void> createPost({required String content, required String authorUid}) async {
		final col = _colOrNull();
		final post = ForumPost(id: DateTime.now().millisecondsSinceEpoch.toString(), authorUid: authorUid, content: content, createdAt: DateTime.now());
		if (col == null) {
			_offlineQueue.add(post);
			return;
		}
		await col.doc(post.id).set(post.toMap());
		// Try flush any offline posts
		await _flushOffline(col);
	}

	Future<void> _flushOffline(CollectionReference<Map<String, dynamic>> col) async {
		if (_offlineQueue.isEmpty) return;
		final copy = List<ForumPost>.from(_offlineQueue);
		for (final p in copy) {
			await col.doc(p.id).set(p.toMap());
			_offlineQueue.remove(p);
		}
	}

	Future<void> react({required String id, required String field}) async {
		final col = _colOrNull();
		if (col == null) return;
		await col.doc(id).update({field: FieldValue.increment(1)});
	}
}
