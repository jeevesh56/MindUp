import 'package:cloud_firestore/cloud_firestore.dart';
import '../mood/mood_service.dart';
import '../../utils/firebase_readiness.dart';

class StreaksService {
	final MoodService _moodService;
	final String _profileCollection;

	StreaksService({MoodService? moodService, String profileCollection = 'user_profiles'})
		: _moodService = moodService ?? MoodService(),
			_profileCollection = profileCollection;

	FirebaseFirestore? _dbOrNull() {
		if (!FirebaseReadiness.isInitialized) return null;
		return FirebaseFirestore.instance;
	}

	Future<int> computeCurrentStreak({String? userId}) async {
		final entries = await _moodService.streamRecent(days: 60, userId: userId).first;
		final dates = entries.map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day)).toSet();
		int streak = 0;
		DateTime d = DateTime.now();
		while (true) {
			final day = DateTime(d.year, d.month, d.day).subtract(Duration(days: streak));
			if (dates.contains(day)) {
				streak += 1;
			} else {
				break;
			}
		}
		return streak;
	}

	List<String> unlockedRewardsForStreak(int streak) {
		final rewards = <String>[];
		if (streak >= 3) rewards.add('Sticker: Sprout');
		if (streak >= 7) rewards.add('Sticker: Growing');
		if (streak >= 14) rewards.add('Sticker: Flower');
		if (streak >= 30) rewards.add('Avatar: Sun');
		return rewards;
	}

	Future<void> saveRewards({required List<String> rewards, String? userId}) async {
		final db = _dbOrNull();
		if (db == null) return;
		final doc = db.collection(_profileCollection).doc(userId ?? 'anonymous');
		await doc.set({'rewards': rewards}, SetOptions(merge: true));
	}

	Future<List<String>> loadRewards({String? userId}) async {
		final db = _dbOrNull();
		if (db == null) return <String>[];
		final doc = await db.collection(_profileCollection).doc(userId ?? 'anonymous').get();
		final data = doc.data();
		final list = (data?['rewards'] as List?)?.cast<String>() ?? <String>[];
		return list;
	}
}
