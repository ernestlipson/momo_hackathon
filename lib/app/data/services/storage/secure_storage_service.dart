import 'package:get_storage/get_storage.dart';
import 'dart:convert';

/// Secure storage service for sensitive data like tokens
class SecureStorageService {
  static const String _box = 'secure_storage';
  static const String _keyAuth = 'auth_token';
  static const String _keyRefresh = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyDeviceId = 'device_id';

  GetStorage? _storage;
  bool _isInitialized = false;

  /// Initialize secure storage
  Future<void> init() async {
    if (_isInitialized) return;

    await GetStorage.init(_box);
    _storage = GetStorage(_box);
    _isInitialized = true;
  }

  /// Ensure storage is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Get storage instance (lazy initialization)
  GetStorage get storage {
    if (_storage == null || !_isInitialized) {
      throw Exception(
        'SecureStorageService not initialized. Call init() first.',
      );
    }
    return _storage!;
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
    await _ensureInitialized();
    final encrypted = _encrypt(token);
    await storage.write(_keyAuth, encrypted);
  }

  /// Retrieve authentication token
  String? getAuthToken() {
    if (!_isInitialized) return null;

    final encrypted = storage.read(_keyAuth);
    if (encrypted == null) return null;

    try {
      return _decrypt(encrypted);
    } catch (e) {
      // Token corrupted, remove it
      storage.remove(_keyAuth);
      return null;
    }
  }

  /// Store refresh token securely
  Future<void> storeRefreshToken(String token) async {
    await _ensureInitialized();
    final encrypted = _encrypt(token);
    await storage.write(_keyRefresh, encrypted);
  }

  /// Retrieve refresh token
  String? getRefreshToken() {
    if (!_isInitialized) return null;

    final encrypted = storage.read(_keyRefresh);
    if (encrypted == null) return null;

    try {
      return _decrypt(encrypted);
    } catch (e) {
      storage.remove(_keyRefresh);
      return null;
    }
  }

  /// Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    await _ensureInitialized();
    final jsonString = jsonEncode(userData);
    final encrypted = _encrypt(jsonString);
    await storage.write(_keyUser, encrypted);
  }

  /// Retrieve user data
  Map<String, dynamic>? getUserData() {
    if (!_isInitialized) return null;

    final encrypted = storage.read(_keyUser);
    if (encrypted == null) return null;

    try {
      final decrypted = _decrypt(encrypted);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      storage.remove(_keyUser);
      return null;
    }
  }

  /// Store device ID for fraud detection
  Future<void> storeDeviceId(String deviceId) async {
    await _ensureInitialized();
    await storage.write(_keyDeviceId, deviceId);
  }

  /// Get device ID
  String? getDeviceId() {
    if (!_isInitialized) return null;
    return storage.read(_keyDeviceId);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => getAuthToken() != null;

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _ensureInitialized();
    await storage.erase();
  }

  /// Clear only authentication data
  Future<void> clearAuthData() async {
    await _ensureInitialized();
    await storage.remove(_keyAuth);
    await storage.remove(_keyRefresh);
    await storage.remove(_keyUser);
  }

  /// Store any generic secure data
  Future<void> storeSecureData(String key, String data) async {
    await _ensureInitialized();
    final encrypted = _encrypt(data);
    await storage.write(key, encrypted);
  }

  /// Retrieve any generic secure data
  String? getSecureData(String key) {
    if (!_isInitialized) return null;

    final encrypted = storage.read(key);
    if (encrypted == null) return null;

    try {
      return _decrypt(encrypted);
    } catch (e) {
      storage.remove(key);
      return null;
    }
  }

  /// Check if a key exists
  bool hasKey(String key) {
    if (!_isInitialized) return false;
    return storage.hasData(key);
  }

  /// Remove specific key
  Future<void> removeKey(String key) async {
    await _ensureInitialized();
    await storage.remove(key);
  }
}
