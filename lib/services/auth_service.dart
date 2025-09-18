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

	Future<User?> signInWithEmailAndPassword(String email, String password) async {
		final auth = _authOrNull();
		if (auth == null) throw Exception('Firebase not initialized');
		
		try {
			final credential = await auth.signInWithEmailAndPassword(
				email: email,
				password: password,
			);
			return credential.user;
		} on FirebaseAuthException catch (e) {
			throw _handleAuthException(e);
		}
	}

	Future<User?> createUserWithEmailAndPassword(String email, String password) async {
		final auth = _authOrNull();
		if (auth == null) throw Exception('Firebase not initialized');
		
		try {
			final credential = await auth.createUserWithEmailAndPassword(
				email: email,
				password: password,
			);
			return credential.user;
		} on FirebaseAuthException catch (e) {
			throw _handleAuthException(e);
		}
	}

	Future<void> signOut() async {
		final auth = _authOrNull();
		if (auth == null) return;
		await auth.signOut();
	}

	User? get currentUser {
		final auth = _authOrNull();
		return auth?.currentUser;
	}

	// Stream<User?> get authStateChanges {
	// 	final auth = _authOrNull();
	// 	if (auth == null) return Stream.value(null);
	// 	return auth.authStateChanges;
	// }

	String _handleAuthException(FirebaseAuthException e) {
		switch (e.code) {
			case 'user-not-found':
				return 'No user found with this email address.';
			case 'wrong-password':
				return 'Incorrect password.';
			case 'email-already-in-use':
				return 'An account already exists with this email address.';
			case 'weak-password':
				return 'Password is too weak. Please choose a stronger password.';
			case 'invalid-email':
				return 'Invalid email address.';
			case 'user-disabled':
				return 'This account has been disabled.';
			case 'too-many-requests':
				return 'Too many failed attempts. Please try again later.';
			default:
				return 'Authentication failed: ${e.message}';
		}
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