import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Observable variables
  final isAuthenticated = false.obs;
  final isCheckingAuth = true.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay authentication check to avoid navigation during widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // checkAuthenticationStatus();
    });
  }

  /// Check if user is authenticated and redirect accordingly
  // Future<void> checkAuthenticationStatus() async {
  //   try {
  //     isCheckingAuth.value = true;

  //     // Check if user has valid authentication token
  //     final authToken = _storageService.getAuthToken();
  //     var userData = _storageService.getUserData();

  //     if (authToken != null && authToken.isNotEmpty) {
  //       // User has token, check if we have user data
  //       if (userData == null) {
  //         // Token exists but no user data - fetch from API
  //         print('🔄 Token found but no user data, fetching from API...');
  //         userData = await _authService.fetchUserProfile();
  //       }

  //       if (userData != null) {
  //         // User is fully authenticated
  //         isAuthenticated.value = true;

  //         // Set user data
  //         final firstName = userData['firstName'] as String? ?? '';
  //         final lastName = userData['lastName'] as String? ?? '';
  //         userName.value = '$firstName $lastName'.trim();
  //         userEmail.value = userData['email'] as String? ?? '';

  //         print('✅ User is authenticated: ${userName.value}');
  //       } else {
  //         // Failed to get user data - redirect to login
  //         isAuthenticated.value = false;
  //         print('⚠️ Failed to fetch user data - redirecting to login');
  //         Get.offAllNamed('/login');
  //       }
  //     } else {
  //       // No token - user is not authenticated
  //       isAuthenticated.value = false;
  //       print('⚠️ No auth token found - redirecting to login');
  //       Get.offAllNamed('/login');
  //     }
  //   } catch (e) {
  //     print('❌ Error checking authentication: $e');

  //     // On error, assume not authenticated
  //     isAuthenticated.value = false;
  //     Get.offAllNamed('/login');
  //   } finally {
  //     isCheckingAuth.value = false;
  //   }
  // }
}
