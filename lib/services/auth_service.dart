import 'simple_auth_service.dart';

class AuthService {
	final SimpleAuthService _simpleAuth = SimpleAuthService();

	Future<String?> ensureSignedIn() async {
		final isSignedIn = await _simpleAuth.isSignedIn();
		if (isSignedIn) {
			return await _simpleAuth.getCurrentUserEmail();
		}
		final success = await _simpleAuth.signInAnonymously();
		return success ? await _simpleAuth.getCurrentUserEmail() : null;
	}

	Future<String?> signInWithEmailAndPassword(String email, String password) async {
		final success = await _simpleAuth.signInWithEmailAndPassword(email, password);
		if (success) {
			return await _simpleAuth.getCurrentUserEmail();
		}
		throw Exception('Invalid email or password');
	}

	Future<String?> createUserWithEmailAndPassword(String email, String password) async {
		final success = await _simpleAuth.createUserWithEmailAndPassword(email, password);
		if (success) {
			return await _simpleAuth.getCurrentUserEmail();
		}
		throw Exception('Email already exists or invalid email');
	}

	Future<void> signOut() async {
		await _simpleAuth.signOut();
	}

	String? get currentUser {
		return _simpleAuth.getCurrentUser();
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