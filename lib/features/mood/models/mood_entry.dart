import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
	final String id;
	final int moodScore; // 1-10
	final String? note;
	final DateTime createdAt;

	MoodEntry({required this.id, required this.moodScore, this.note, required this.createdAt});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'moodScore': moodScore,
			'note': note,
			'createdAt': Timestamp.fromDate(createdAt.toUtc()),
		};
	}

	factory MoodEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
		final data = doc.data() ?? <String, dynamic>{};
		final ts = data['createdAt'];
		DateTime dt;
		if (ts is Timestamp) {
			dt = ts.toDate();
		} else if (ts is DateTime) {
			dt = ts;
		} else {
			dt = DateTime.now();
		}
		return MoodEntry(
			id: data['id'] as String? ?? doc.id,
			moodScore: (data['moodScore'] as num?)?.toInt() ?? 5,
			note: data['note'] as String?,
			createdAt: dt,
		);
	}
}







