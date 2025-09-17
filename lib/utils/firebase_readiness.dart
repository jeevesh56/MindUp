import 'package:firebase_core/firebase_core.dart';

class FirebaseReadiness {
	static bool get isInitialized => Firebase.apps.isNotEmpty;

	static Future<bool> ensureInitialized() async {
		if (isInitialized) return true;
		try {
			await Firebase.initializeApp();
			return true;
		} catch (_) {
			return false;
		}
	}
}


