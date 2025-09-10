import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/services/storage/secure_storage_service.dart';

class AuthController extends GetxController {
  final SecureStorageService _storageService = Get.find<SecureStorageService>();

  // Observable variables
  final isAuthenticated = false.obs;
  final isCheckingAuth = true.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthenticationStatus();
  }

  /// Check if user is authenticated and redirect accordingly
  Future<void> checkAuthenticationStatus() async {
    try {
      isCheckingAuth.value = true;

      // Check if user has valid authentication token
      final authToken = _storageService.getAuthToken();
      final userData = _storageService.getUserData();

      if (authToken != null && authToken.isNotEmpty && userData != null) {
        // User is authenticated
        isAuthenticated.value = true;

        // Set user data
        final firstName = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';
        userName.value = '$firstName $lastName'.trim();
        userEmail.value = userData['email'] as String? ?? '';

        print('✅ User is authenticated: ${userName.value}');
      } else {
        // User is not authenticated
        isAuthenticated.value = false;

        print('⚠️ User not authenticated - redirecting to login');

        // Navigate to login screen
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('❌ Error checking authentication: $e');

      // On error, assume not authenticated
      isAuthenticated.value = false;
      Get.offAllNamed('/login');
    } finally {
      isCheckingAuth.value = false;
    }
  }

  /// Logout user and clear session
  Future<void> logout() async {
    try {
      // Clear all stored authentication data
      await _storageService.clearAuthData();

      // Update state
      isAuthenticated.value = false;
      userName.value = '';
      userEmail.value = '';

      print('✅ User logged out successfully');

      // Navigate to login screen
      Get.offAllNamed('/login');

      // Show success message
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error during logout: $e');

      // Force logout even if there's an error
      isAuthenticated.value = false;
      Get.offAllNamed('/login');
    }
  }

  /// Force authentication check (useful for refreshing auth status)
  Future<void> refreshAuthStatus() async {
    await checkAuthenticationStatus();
  }

  /// Check if user has valid session without navigation
  bool get hasValidSession {
    final authToken = _storageService.getAuthToken();
    final userData = _storageService.getUserData();
    return authToken != null && authToken.isNotEmpty && userData != null;
  }

  /// Get current user data
  Map<String, dynamic>? get currentUserData {
    return _storageService.getUserData();
  }

  /// Update user data in memory and storage
  Future<void> updateUserData(Map<String, dynamic> newUserData) async {
    try {
      // Update storage
      await _storageService.storeUserData(newUserData);

      // Update observable data
      final firstName = newUserData['firstName'] as String? ?? '';
      final lastName = newUserData['lastName'] as String? ?? '';
      userName.value = '$firstName $lastName'.trim();
      userEmail.value = newUserData['email'] as String? ?? '';

      print('✅ User data updated: ${userName.value}');
    } catch (e) {
      print('❌ Error updating user data: $e');
    }
  }
}
