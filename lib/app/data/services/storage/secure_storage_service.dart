import 'package:get_storage/get_storage.dart';
import 'dart:convert';

/// Secure storage service for sensitive data like tokens
class SecureStorageService {
  static const String _box = 'secure_storage';
  static const String _keyAuth = 'auth_token';
  static const String _keyRefresh = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyDeviceId = 'device_id';

  late final GetStorage _storage;

  /// Initialize secure storage
  Future<void> init() async {
    await GetStorage.init(_box);
    _storage = GetStorage(_box);
  }

  /// Encrypt data before storage
  String _encrypt(String data) {
    // Simple base64 encoding for demo
    // In production, use proper AES encryption
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  /// Decrypt data after retrieval
  String _decrypt(String encryptedData) {
    try {
      final bytes = base64Decode(encryptedData);
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  /// Store authentication token securely
  Future<void> storeAuthToken(String token) async {
    final encrypted = _encrypt(token);
    await _storage.write(_keyAuth, encrypted);
  }

  /// Retrieve authentication token
  String? getAuthToken() {
    final encrypted = _storage.read(_keyAuth);
    if (encrypted == null) return null;

    try {
      return _decrypt(encrypted);
    } catch (e) {
      // Token corrupted, remove it
      _storage.remove(_keyAuth);
      return null;
    }
  }

  /// Store refresh token securely
  Future<void> storeRefreshToken(String token) async {
    final encrypted = _encrypt(token);
    await _storage.write(_keyRefresh, encrypted);
  }

  /// Retrieve refresh token
  String? getRefreshToken() {
    final encrypted = _storage.read(_keyRefresh);
    if (encrypted == null) return null;

    try {
      return _decrypt(encrypted);
    } catch (e) {
      _storage.remove(_keyRefresh);
      return null;
    }
  }

  /// Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    final encrypted = _encrypt(jsonString);
    await _storage.write(_keyUser, encrypted);
  }

  /// Retrieve user data
  Map<String, dynamic>? getUserData() {
    final encrypted = _storage.read(_keyUser);
    if (encrypted == null) return null;

    try {
      final decrypted = _decrypt(encrypted);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      _storage.remove(_keyUser);
      return null;
    }
  }

  /// Store device ID for fraud detection
  Future<void> storeDeviceId(String deviceId) async {
    await _storage.write(_keyDeviceId, deviceId);
  }

  /// Get device ID
  String? getDeviceId() {
    return _storage.read(_keyDeviceId);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => getAuthToken() != null;

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.erase();
  }

  /// Clear only authentication data
  Future<void> clearAuthData() async {
    await _storage.remove(_keyAuth);
    await _storage.remove(_keyRefresh);
    await _storage.remove(_keyUser);
  }

  /// Store any generic secure data
  Future<void> storeSecureData(String key, String data) async {
    final encrypted = _encrypt(data);
    await _storage.write(key, encrypted);
  }

  /// Retrieve any generic secure data
  String? getSecureData(String key) {
    final encrypted = _storage.read(key);
    if (encrypted == null) return null;

    try {
      return _decrypt(encrypted);
    } catch (e) {
      _storage.remove(key);
      return null;
    }
  }

  /// Check if a key exists
  bool hasKey(String key) {
    return _storage.hasData(key);
  }

  /// Remove specific key
  Future<void> removeKey(String key) async {
    await _storage.remove(key);
  }
}
