import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
	final String id;
	final String authorUid;
	final String content;
	final DateTime createdAt;
	final int hugs;
	final int highFives;

	ForumPost({required this.id, required this.authorUid, required this.content, required this.createdAt, this.hugs = 0, this.highFives = 0});

	Map<String, dynamic> toMap() => {
		'id': id,
		'authorUid': authorUid,
		'content': content,
		'createdAt': Timestamp.fromDate(createdAt),
		'hugs': hugs,
		'highFives': highFives,
	};

	factory ForumPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
		final d = doc.data() ?? <String, dynamic>{};
		final ts = d['createdAt'];
		final dt = ts is Timestamp ? ts.toDate() : DateTime.now();
		return ForumPost(
			id: d['id'] as String? ?? doc.id,
			authorUid: d['authorUid'] as String? ?? 'anon',
			content: d['content'] as String? ?? '',
			createdAt: dt,
			hugs: (d['hugs'] as num?)?.toInt() ?? 0,
			highFives: (d['highFives'] as num?)?.toInt() ?? 0,
		);
	}
}




