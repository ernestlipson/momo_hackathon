import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/models/signup_request.dart';
import 'package:momo_hackathon/app/data/services/auth_service.dart';
import 'package:momo_hackathon/app/data/models/network_exception.dart';

class SignupController extends GetxController {
  // Services
  final AuthService _authService = Get.find<AuthService>();

  // Step 1 - Email & Password
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();

  // Step 2 - Personal Details
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final personalFormKey = GlobalKey<FormState>();

  // Observable variables
  final currentStep = 1.obs;
  final isLoading = false.obs;
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;
  final isFirstNameValid = false.obs;
  final isLastNameValid = false.obs;
  final selectedLocation = Rxn<GhanaRegion>();
  final passwordVisible = false.obs;

  // Validation patterns
  static const emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  @override
  void onInit() {
    super.onInit();
    _setupValidation();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  /// Setup real-time validation for all fields
  void _setupValidation() {
    // Step 1 validation
    emailController.addListener(() {
      isEmailValid.value = _isValidEmail(emailController.text);
    });

    passwordController.addListener(() {
      isPasswordValid.value = _isValidPassword(passwordController.text);
    });

    // Step 2 validation
    firstNameController.addListener(() {
      isFirstNameValid.value = _isValidName(firstNameController.text);
    });

    lastNameController.addListener(() {
      isLastNameValid.value = _isValidName(lastNameController.text);
    });
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    return email.isNotEmpty && RegExp(emailPattern).hasMatch(email);
  }

  /// Check if password is valid
  bool _isValidPassword(String password) {
    return password.isNotEmpty && RegExp(passwordPattern).hasMatch(password);
  }

  /// Check if name is valid (first name or last name)
  bool _isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  /// Check if step 1 form is valid
  bool get isStep1Valid => isEmailValid.value && isPasswordValid.value;

  /// Check if step 2 form is valid
  bool get isStep2Valid {
    return isFirstNameValid.value &&
        isLastNameValid.value &&
        selectedLocation.value != null;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  /// Proceed to step 2
  void proceedToStep2() {
    if (emailFormKey.currentState!.validate() && isStep1Valid) {
      currentStep.value = 2;
      Get.toNamed('/signup-step2');
    }
  }

  /// Go back to step 1
  void backToStep1() {
    currentStep.value = 1;
    Get.back();
  }

  /// Show location selection bottom sheet
  void showLocationPicker() {
    Get.bottomSheet(
      _buildLocationBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  /// Build location selection bottom sheet
  Widget _buildLocationBottomSheet() {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location list
          Flexible(
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: GhanaRegion.all.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final region = GhanaRegion.all[index];
                return ListTile(
                  title: Text(region.displayName),
                  // subtitle: Text(region.code),
                  trailing: Obx(
                    () => selectedLocation.value == region
                        ? const Icon(Icons.check, color: Color(0xFF7C3AED))
                        : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    selectedLocation.value = region;
                    Get.back();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Complete signup process
  Future<void> completeSignup() async {
    if (!personalFormKey.currentState!.validate() || !isStep2Valid) {
      return;
    }

    try {
      isLoading.value = true;

      // Create signup request
      final signupRequest = SignupRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        location: selectedLocation.value!.code,
      );

      // Call registration API
      final response = await _authService.register(signupRequest);

      // Navigate to success page with user data
      Get.offAllNamed(
        '/signup-success',
        arguments: {
          'firstName': response.user.firstName,
          'lastName': response.user.lastName,
          'email': response.user.email,
          'userId': response.userId,
        },
      );
    } on ValidationException catch (e) {
      _handleValidationError(e);
    } on NetworkException catch (e) {
      _handleNetworkError(e);
    } catch (e) {
      // Get.snackbar(
      //   'Registration Failed',
      //   'An unexpected error occurred. Please try again. $e',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.red.withOpacity(0.8),
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 3),
      // );
      // Get.log("Error Occured: $e");
      // print('❌ Unexpected signup error: $e');
    } finally {
      isLoading.value = false;
    }
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
    String message = 'Registration failed. Please try again.';

    if (e is ConnectionException) {
      message =
          'No internet connection. Please check your network and try again.';
    } else if (e is ServerException) {
      message = e.message;
    } else if (e is AuthenticationException) {
      message = 'Registration failed. Please check your details and try again.';
    }

    Get.log("Network Error Occured: $e ${e.statusCode} ${e.message}");

    Get.snackbar(
      'Registration Failed',
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// First name validator
  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  /// Last name validator
  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  /// Navigate to login page
  void navigateToLogin() {
    Get.offNamed("/login");
  }
}
