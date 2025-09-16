import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/firebase_readiness.dart';
import 'models/forum_post.dart';

class ForumService {
	final String _collection;

	ForumService({String collection = 'forum_posts'}) : _collection = collection;

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
		if (col == null) return;
		final id = col.doc().id;
		final post = ForumPost(id: id, authorUid: authorUid, content: content, createdAt: DateTime.now());
		await col.doc(id).set(post.toMap());
	}

	Future<void> react({required String id, required String field}) async {
		final col = _colOrNull();
		if (col == null) return;
		await col.doc(id).update({field: FieldValue.increment(1)});
	}
}
