import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseReadiness {
	static bool get isInitialized => Firebase.apps.isNotEmpty;

	static Future<bool> ensureInitialized() async {
		if (isInitialized) return true;
		try {
			await Firebase.initializeApp(
				options: DefaultFirebaseOptions.currentPlatform,
			);
			return true;
		} catch (e) {
			print('Firebase initialization error: $e');
			return false;
		}
	}
}


