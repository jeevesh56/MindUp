import 'package:firebase_auth/firebase_auth.dart';
import '../utils/firebase_readiness.dart';

class AuthService {
	FirebaseAuth? _authOrNull() {
		if (!FirebaseReadiness.isInitialized) return null;
		return FirebaseAuth.instance;
	}

	Future<User?> ensureSignedIn() async {
		final auth = _authOrNull();
		if (auth == null) return null;
		final current = auth.currentUser;
		if (current != null) return current;
		final cred = await auth.signInAnonymously();
		return cred.user;
	}

	String aliasForUid(String uid) {
		int hash = 0;
		for (final codeUnit in uid.codeUnits) {
			hash = (hash * 31 + codeUnit) & 0x7fffffff;
		}
		final number = 100 + (hash % 900);
		return 'Anonymous #$number';
	}
}
