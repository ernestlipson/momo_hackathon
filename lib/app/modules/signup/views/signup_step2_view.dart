import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignupStep2View extends GetView<SignupController> {
  const SignupStep2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: controller.backToStep1,
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.personalFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your profile to finish setting up your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 48),

                // Progress indicator
                _buildProgressIndicator(),

                const SizedBox(height: 40),

                // Name fields
                Row(
                  children: [
                    Expanded(child: _buildFirstNameField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLastNameField()),
                  ],
                ),

                const SizedBox(height: 24),

                // Location field
                _buildLocationField(),

                const SizedBox(height: 48),

                // Create account button
                _buildCreateAccountButton(),

                const SizedBox(height: 24),

                // Terms and privacy
                _buildTermsAndPrivacy(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        // Step 1 (completed)
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Colors.black, size: 16),
          ),
        ),

        // Line (completed)
        Expanded(
          child: Container(
            height: 2,
            color: const Color(0xFF7C3AED),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),

        // Step 2 (current)
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF7C3AED),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '2',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'First Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller.firstNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: controller.validateFirstName,
            decoration: InputDecoration(
              hintText: 'John',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.person_outlined, color: Colors.grey[400]),
              suffixIcon: controller.isFirstNameValid.value
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller.lastNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: controller.validateLastName,
            decoration: InputDecoration(
              hintText: 'Doe',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.person_outlined, color: Colors.grey[400]),
              suffixIcon: controller.isLastNameValid.value
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => InkWell(
            onTap: controller.showLocationPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.selectedLocation.value?.displayName ??
                          'Select your region',
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.selectedLocation.value != null
                            ? Colors.black87
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ),
        // Validation message for location
        Obx(
          () => controller.selectedLocation.value == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select your location',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : (controller.isStep2Valid ? controller.completeSignup : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.isStep2Valid
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'By creating an account, you agree to our Terms of Service and Privacy Policy',
        style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}
