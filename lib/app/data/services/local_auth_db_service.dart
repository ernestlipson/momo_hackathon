import 'package:hive/hive.dart';

class LocalAuthDbService {
  static const String _authBox = 'authBox';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyUserData = 'user_data';

  static Future<void> init() async {
    await Hive.openBox(_authBox);
  }

  static Box<dynamic> get _box => Hive.box(_authBox);

  // Store auth token
  static Future<void> storeAuthToken(String token) async {
    await _box.put(_keyAuthToken, token);
  }

  // Retrieve auth token
  static String? getAuthToken() {
    return _box.get(_keyAuthToken);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _box.put(_keyRefreshToken, token);
  }

  // Retrieve refresh token
  static String? getRefreshToken() {
    return _box.get(_keyRefreshToken);
  }

  // Set user logged in state
  static Future<void> setLoggedIn(bool value) async {
    await _box.put(_keyLoggedIn, value);
  }

  // Check if user has logged in
  static bool get hasLoggedInBefore {
    return _box.get(_keyLoggedIn, defaultValue: false) == true;
  }

  // Store user data
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    await _box.put(_keyUserData, userData);
  }

  // Retrieve user data
  static Map<String, dynamic>? getUserData() {
    final data = _box.get(_keyUserData);
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Clear all auth data
  static Future<void> clearAll() async {
    await _box.delete(_keyAuthToken);
    await _box.delete(_keyRefreshToken);
    await _box.delete(_keyLoggedIn);
    await _box.delete(_keyUserData);
  }
}
