import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/models/login_request.dart';
import 'package:momo_hackathon/app/data/services/auth_service.dart';
import 'package:momo_hackathon/app/data/models/network_exception.dart';

class LoginController extends GetxController {
  // Services
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final isLoading = false.obs;
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;
  final passwordVisible = false.obs;

  // Validation patterns
  static const emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  @override
  void onInit() {
    super.onInit();
    _setupValidation();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Setup real-time validation for email and password
  void _setupValidation() {
    emailController.addListener(() {
      isEmailValid.value = _isValidEmail(emailController.text);
    });

    passwordController.addListener(() {
      isPasswordValid.value = passwordController.text.isNotEmpty;
    });
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    return email.isNotEmpty && RegExp(emailPattern).hasMatch(email);
  }

  /// Check if form is valid and both fields are filled
  bool get isFormValid =>
      isEmailValid.value &&
      isPasswordValid.value &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  /// Navigate to signup
  void goToSignup() {
    Get.toNamed('/signup');
  }

  /// Perform login
  Future<void> login() async {
    if (!formKey.currentState!.validate() || !isFormValid) {
      return;
    }

    try {
      isLoading.value = true;

      // Create login request
      final loginRequest = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Call login API
      await _authService.login(loginRequest);

      // Show success message
      Get.snackbar(
        'Login Successful',
        'Welcome back! You have been logged in successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to main app
      Get.offAllNamed('/');
    } on AuthenticationException catch (e) {
      _handleAuthError(e);
    } on ValidationException catch (e) {
      _handleValidationError(e);
    } on NetworkException catch (e) {
      _handleNetworkError(e);
    } catch (e) {
      Get.log('Login error: $e');
      Get.snackbar(
        'Login Failed',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      print('❌ Unexpected login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle authentication errors
  void _handleAuthError(AuthenticationException e) {
    String message =
        'Invalid email or password. Please check your credentials and try again.';

    // Customize message based on error code
    switch (e.errorCode) {
      case 'INVALID_CREDENTIALS':
        message = 'Invalid email or password. Please check your credentials.';
        break;
      case 'ACCOUNT_LOCKED':
        message = 'Account is temporarily locked. Please try again later.';
        break;
      case 'ACCOUNT_DISABLED':
        message = 'Account is disabled. Please contact support.';
        break;
      default:
        message = e.message;
    }

    Get.snackbar(
      'Login Failed',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Handle validation errors
  void _handleValidationError(ValidationException e) {
    String message = e.message;

    // Handle field-specific errors
    if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
      final errors = <String>[];
      e.fieldErrors!.forEach((field, fieldErrors) {
        errors.addAll(fieldErrors);
      });
      message = errors.join('\n');
    }

    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Handle network errors
  void _handleNetworkError(NetworkException e) {
    String message = 'Login failed. Please try again.';

    if (e is ConnectionException) {
      message =
          'No internet connection. Please check your network and try again.';
    } else if (e is ServerException) {
      message = 'Server error. Please try again later.';
    } else if (e is RateLimitException) {
      message = 'Too many login attempts. Please wait a moment and try again.';
    }

    Get.snackbar(
      'Connection Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
}
