import 'package:shared_preferences/shared_preferences.dart';

class SimpleAuthService {
  static const String _userKey = 'logged_in_user';
  static const String _emailKey = 'user_email';
  
  // Simple user data structure
  static Map<String, String> _users = {
    'admin@mindup.com': 'admin123',
    'user@mindup.com': 'user123',
    'test@mindup.com': 'test123',
  };

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (_users.containsKey(email) && _users[email] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_userKey, true);
      await prefs.setString(_emailKey, email);
      return true;
    }
    return false;
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!_users.containsKey(email)) {
      _users[email] = password;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_userKey, true);
      await prefs.setString(_emailKey, email);
      return true;
    }
    return false;
  }

  Future<bool> signInAnonymously() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userKey, true);
    await prefs.setString(_emailKey, 'anonymous@mindup.com');
    return true;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_emailKey);
  }

  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userKey) ?? false;
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  String getCurrentUser() {
    return 'current_user';
  }
}
