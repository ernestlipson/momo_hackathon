import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/services/local_auth_db_service.dart';
import '../models/signup_request.dart';
import '../models/signup_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'network/base_network_service.dart';

/// Authentication service for user registration and login
class AuthService extends GetxService {
  final BaseNetworkService _networkService = Get.find<BaseNetworkService>();

  Future<void> storeData(
    String token,
    String refreshToken, [
    Map<String, dynamic>? userData,
  ]) async {
    await LocalAuthDbService.storeAuthToken(token);
    await LocalAuthDbService.storeRefreshToken(refreshToken);
    if (userData != null) {
      await LocalAuthDbService.storeUserData(userData);
    }
  }

  Future<SignupResponse?> register(SignupRequest request) async {
    try {
      final response = await _networkService.post(
        '/auth/register',
        data: request.toJson(),
      );
      if (response != null &&
          response.statusCode == 200 &&
          response.data != null) {
        final signupResponse = SignupResponse.fromJson(response.data);
        await storeData(
          signupResponse.token,
          signupResponse.token,
          signupResponse.user.toJson(),
        );
        return signupResponse;
      }
      return null;
    } catch (e) {
      Get.log('❌ Register error: $e');
      return null;
    }
  }

  Future<LoginResponse?> login(LoginRequest request) async {
    try {
      final response = await _networkService.post(
        '/auth/login',
        data: request.toJson(),
      );
      Get.log('🔵 Login response: ${response?.data}');
      if (response != null &&
          response.statusCode == 200 &&
          response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await storeData(loginResponse.token, loginResponse.token);
        await _fetchUserProfile();
        Get.log('✅ User logged in successfully: ${request.email}');
        return loginResponse;
      }
      return null;
    } catch (e) {
      Get.log('❌ Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    try {
      final response = await _networkService.get('/auth/me');
      if (response != null &&
          response.statusCode == 200 &&
          response.data != null) {
        final userData = response.data['user'] as Map<String, dynamic>?;
        if (userData != null) {
          await LocalAuthDbService.storeUserData(userData);
        }
        return userData;
      }
      return null;
    } catch (e) {
      Get.log('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    final token = LocalAuthDbService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if user has complete session (token + user data)
  bool get hasValidSession {
    final token = LocalAuthDbService.getAuthToken();
    final userData = LocalAuthDbService.getUserData();
    return token != null && token.isNotEmpty && userData != null;
  }
}
