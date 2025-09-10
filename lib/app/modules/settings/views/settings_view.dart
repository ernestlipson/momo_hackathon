import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Settings Title
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Settings List
                    Obx(
                      () => Column(
                        children: controller.settingsOptions
                            .map((option) => _buildSettingsItem(option))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(SettingsOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(option.icon, color: const Color(0xFF7C3AED), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildSettingsControl(option),
        ],
      ),
    );
  }

  Widget _buildSettingsControl(SettingsOption option) {
    switch (option.type) {
      case SettingsOptionType.toggle:
        return Obx(
          () => Switch(
            value: controller.getToggleValue(option.key),
            onChanged: (value) =>
                controller.onSettingChanged(option.key, value),
            activeThumbColor: const Color(0xFF7C3AED),
          ),
        );
      case SettingsOptionType.navigation:
        return GestureDetector(
          onTap: () => controller.onSettingTapped(option.key),
          child: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF7C3AED),
            size: 16,
          ),
        );
    }
  }
}
