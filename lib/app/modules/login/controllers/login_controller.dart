import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/models/login_request.dart';
import 'package:momo_hackathon/app/data/services/auth_service.dart';
import 'package:momo_hackathon/app/data/services/local_auth_db_service.dart';

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
    isLoading.value = true;
    try {
      final loginRequest = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final loginResponse = await _authService.login(loginRequest);
      if (loginResponse != null) {
        await LocalAuthDbService.setLoggedIn(true);
        Get.snackbar(
          'Login Successful',
          'Welcome back! You have been logged in successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAllNamed('/');
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid email or password. Please check your credentials and try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ Unexpected login error: $e');
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
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
