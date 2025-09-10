import 'package:get/get.dart';
import '../models/signup_request.dart';
import '../models/signup_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/network_exception.dart';
import 'network/base_network_service.dart';
import 'storage/secure_storage_service.dart';

/// Authentication service for user registration and login
class AuthService extends GetxService {
  final BaseNetworkService _networkService = Get.find<BaseNetworkService>();
  final SecureStorageService _storageService = Get.find<SecureStorageService>();

  /// Register a new user
  ///
  /// Takes a [SignupRequest] with user details and returns [SignupResponse]
  /// with user data and authentication tokens.
  ///
  /// Throws [NetworkException] on network errors
  /// Throws [ValidationException] on validation errors
  /// Throws [ServerException] on server errors
  Future<SignupResponse> register(SignupRequest request) async {
    try {
      // Make POST request to registration endpoint
      final response = await _networkService.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      // Handle successful response
      if (response.success && response.data != null) {
        final signupResponse = SignupResponse.fromJson(response.data!);

        // Store authentication tokens securely
        await _storeAuthTokens(
          signupResponse.token,
          signupResponse.refreshToken,
        );

        // Store user data
        await _storageService.storeUserData(signupResponse.user.toJson());

        print('✅ User registered successfully: ${signupResponse.user.email}');
        return signupResponse;
      }

      // Handle API error response
      throw ServerException(
        message: 'Registration failed: ${response.message}',
        statusCode: response.statusCode ?? 500,
        errorCode: response.errorCode,
      );
    } on NetworkException {
      // Re-throw network exceptions as-is
      rethrow;
    } catch (e) {
      // Handle unexpected errors
      throw ServerException(
        message: 'Unexpected error during registration: ${e.toString()}',
      );
    }
  }

  /// Login an existing user
  ///
  /// Takes a [LoginRequest] with email and password and returns [LoginResponse]
  /// with authentication tokens.
  ///
  /// Throws [NetworkException] on network errors
  /// Throws [ValidationException] on validation errors
  /// Throws [AuthenticationException] on authentication errors
  /// Throws [ServerException] on server errors
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // Make POST request to login endpoint
      final response = await _networkService.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      // Handle successful response
      if (response.success && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);

        // Store authentication tokens securely
        await _storeAuthTokens(loginResponse.token, loginResponse.refreshToken);

        print('✅ User logged in successfully: ${request.email}');
        return loginResponse;
      }

      // Handle API error response
      throw AuthenticationException(
        message: 'Login failed: ${response.message}',
        statusCode: response.statusCode ?? 401,
        errorCode: response.errorCode,
      );
    } on NetworkException {
      // Re-throw network exceptions as-is
      rethrow;
    } catch (e) {
      // Handle unexpected errors
      throw ServerException(
        message: 'Unexpected error during login: ${e.toString()}',
      );
    }
  }

  /// Store authentication tokens securely
  Future<void> _storeAuthTokens(String token, String refreshToken) async {
    try {
      await _storageService.storeAuthToken(token);
      await _storageService.storeRefreshToken(refreshToken);
    } catch (e) {
      print('⚠️ Warning: Failed to store auth tokens: $e');
      // Don't throw here as registration was successful
    }
  }

  /// Check if email is available (placeholder for future implementation)
  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _networkService.get<Map<String, dynamic>>(
        '/auth/check-email',
        queryParameters: {'email': email},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response.success && (response.data?['available'] ?? false);
    } catch (e) {
      print('❌ Error checking email availability: $e');
      // Return true to not block registration on check failure
      return true;
    }
  }

  /// Get current user data from storage
  Map<String, dynamic>? getCurrentUser() {
    return _storageService.getUserData();
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    final token = _storageService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    try {
      // Clear authentication data
      await _storageService.clearAuthData();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      throw ServerException(
        message: 'Failed to logout properly: ${e.toString()}',
      );
    }
  }
}
