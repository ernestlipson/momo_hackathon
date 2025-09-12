import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/fraud_result.dart';
import '../../../data/models/sms_message.dart' as app_models;
import '../../sms_scanner/controllers/sms_scanner_controller.dart';

class FraudMessagesController extends GetxController {
  final SmsScannerController _smsController = Get.find<SmsScannerController>();

  // Observable list for fraud messages only
  final fraudMessages = <FraudResult>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFraudMessages();
  }

  void _loadFraudMessages() {
    isLoading.value = true;

    // Filter only fraud messages from the SMS scanner controller
    final fraudOnly = _smsController.fraudResults
        .where((result) => result.isFraud)
        .toList();

    fraudMessages.assignAll(fraudOnly);
    isLoading.value = false;
  }

  void refreshFraudMessages() {
    _loadFraudMessages();
  }

  // Get the SMS message details for a fraud result
  app_models.SmsMessage? getMessageForResult(FraudResult result) {
    return _smsController.scannedMessages.firstWhereOrNull(
      (msg) => msg.id == result.messageId,
    );
  }

  // Clear all fraud messages
  void clearAllFraudMessages() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Fraud Messages'),
        content: const Text(
          'Are you sure you want to clear all fraud detection results?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Remove fraud messages from the main controller
              _smsController.fraudResults.removeWhere(
                (result) => result.isFraud,
              );
              _smsController.fraudDetected.value = 0;

              // Clear local list
              fraudMessages.clear();
              Get.back();

              Get.snackbar(
                'Success',
                'All fraud messages cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
