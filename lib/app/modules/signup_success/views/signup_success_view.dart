import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_success_controller.dart';

class SignupSuccessView extends GetView<SignupSuccessController> {
  const SignupSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation/Icon
              _buildSuccessIcon(),

              const SizedBox(height: 32),

              // Success Title
              const Text(
                'Account Created Successfully!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Welcome Message
              Text(
                controller.welcomeMessage,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Success Description
              Text(
                'Your fraud detection account is ready to protect you from mobile money scams.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Countdown Display
              _buildCountdownSection(),

              const SizedBox(height: 32),

              // Skip Button
              _buildSkipButton(),

              const SizedBox(height: 24),

              // App Branding
              Text(
                'CatchDem • Fraud Detection Platform',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
      ),
      child: const Icon(Icons.check_circle, size: 60, color: Colors.green),
    );
  }

  Widget _buildCountdownSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Countdown Circle
          Obx(
            () => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: controller.isCountdownActive.value
                    ? Text(
                        '${controller.countdown.value}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Countdown Message
          Obx(
            () => Text(
              controller.countdownMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Obx(
      () => controller.isCountdownActive.value
          ? TextButton.icon(
              onPressed: controller.skipToHome,
              icon: const Icon(Icons.skip_next, color: Color(0xFF7C3AED)),
              label: const Text(
                'Skip to Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C3AED),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
