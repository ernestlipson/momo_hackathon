import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Observable variables for settings
  final isDarkMode = false.obs;
  final notificationsEnabled = true.obs;
  final autoScanEnabled = false.obs;
  final selectedNavIndex = 2.obs;

  // Settings options
  final settingsOptions = <SettingsOption>[
    SettingsOption(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      subtitle: 'Receive alerts for deals and offers',
      type: SettingsOptionType.toggle,
      key: 'notifications',
    ),
    SettingsOption(
      icon: Icons.qr_code_scanner_outlined,
      title: 'Auto Scan',
      subtitle: 'Automatically scan when camera opens',
      type: SettingsOptionType.toggle,
      key: 'autoScan',
    ),
    SettingsOption(
      icon: Icons.dark_mode_outlined,
      title: 'Dark Mode',
      subtitle: 'Enable dark theme',
      type: SettingsOptionType.toggle,
      key: 'darkMode',
    ),
    SettingsOption(
      icon: Icons.info_outline,
      title: 'About',
      subtitle: 'App version and information',
      type: SettingsOptionType.navigation,
      key: 'about',
    ),
    SettingsOption(
      icon: Icons.help_outline,
      title: 'Help & Support',
      subtitle: 'Get help using the app',
      type: SettingsOptionType.navigation,
      key: 'help',
    ),
    SettingsOption(
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy Policy',
      subtitle: 'Read our privacy policy',
      type: SettingsOptionType.navigation,
      key: 'privacy',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadSettings() {
    // Load settings from local storage
    // In a real app, this would load from SharedPreferences or similar
  }

  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;

    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.toNamed('/history');
        break;
      case 2:
        // Already on Settings
        break;
    }
  }

  void onSettingChanged(String key, bool value) {
    switch (key) {
      case 'notifications':
        notificationsEnabled.value = value;
        _saveNotificationSettings(value);
        break;
      case 'autoScan':
        autoScanEnabled.value = value;
        _saveAutoScanSettings(value);
        break;
      case 'darkMode':
        isDarkMode.value = value;
        _saveDarkModeSettings(value);
        break;
    }
  }

  void onSettingTapped(String key) {
    switch (key) {
      case 'about':
        _showAboutDialog();
        break;
      case 'help':
        _showHelpDialog();
        break;
      case 'privacy':
        _showPrivacyDialog();
        break;
    }
  }

  void _saveNotificationSettings(bool enabled) {
    // Save to local storage
    Get.snackbar(
      'Notifications',
      enabled ? 'Notifications enabled' : 'Notifications disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveAutoScanSettings(bool enabled) {
    // Save to local storage
    Get.snackbar(
      'Auto Scan',
      enabled ? 'Auto scan enabled' : 'Auto scan disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveDarkModeSettings(bool enabled) {
    // Save to local storage and update theme
    Get.snackbar(
      'Theme',
      enabled ? 'Dark mode enabled' : 'Light mode enabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Momo Hackathon App'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A smart shopping assistant that helps you save money by finding the best deals.',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to use the app:'),
            SizedBox(height: 8),
            Text('1. Scan products using the scanner'),
            Text('2. View your savings in real-time'),
            Text('3. Check your scan history'),
            Text('4. Customize your preferences'),
            SizedBox(height: 16),
            Text('For more help, contact: support@momoapp.com'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy Summary:'),
              SizedBox(height: 8),
              Text('• We collect minimal data necessary for app functionality'),
              Text('• Your scan history is stored locally on your device'),
              Text('• We do not share personal information with third parties'),
              Text('• You can delete your data at any time'),
              SizedBox(height: 16),
              Text('For the complete privacy policy, visit our website.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  bool getToggleValue(String key) {
    switch (key) {
      case 'notifications':
        return notificationsEnabled.value;
      case 'autoScan':
        return autoScanEnabled.value;
      case 'darkMode':
        return isDarkMode.value;
      default:
        return false;
    }
  }
}

class SettingsOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final SettingsOptionType type;
  final String key;

  SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.key,
  });
}

enum SettingsOptionType { toggle, navigation }
