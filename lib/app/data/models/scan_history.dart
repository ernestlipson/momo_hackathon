import 'fraud_result.dart';
import 'sms_message.dart';

class ScanHistory {
  final String id;
  final DateTime scanDate;
  final int totalMessagesScanned;
  final int fraudDetected;
  final int legitimateMessages;
  final List<SmsMessage> scannedMessages;
  final List<FraudResult> fraudResults;
  final String scanType; // 'manual', 'background', 'scheduled'

  ScanHistory({
    required this.id,
    required this.scanDate,
    required this.totalMessagesScanned,
    required this.fraudDetected,
    required this.legitimateMessages,
    required this.scannedMessages,
    required this.fraudResults,
    this.scanType = 'manual',
  });

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] ?? '',
      scanDate: DateTime.parse(
        json['scanDate'] ?? DateTime.now().toIso8601String(),
      ),
      totalMessagesScanned: json['totalMessagesScanned'] ?? 0,
      fraudDetected: json['fraudDetected'] ?? 0,
      legitimateMessages: json['legitimateMessages'] ?? 0,
      scannedMessages:
          (json['scannedMessages'] as List<dynamic>?)
              ?.map((msg) => SmsMessage.fromJson(msg))
              .toList() ??
          [],
      fraudResults:
          (json['fraudResults'] as List<dynamic>?)
              ?.map((result) => FraudResult.fromJson(result))
              .toList() ??
          [],
      scanType: json['scanType'] ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scanDate': scanDate.toIso8601String(),
      'totalMessagesScanned': totalMessagesScanned,
      'fraudDetected': fraudDetected,
      'legitimateMessages': legitimateMessages,
      'scannedMessages': scannedMessages.map((msg) => msg.toJson()).toList(),
      'fraudResults': fraudResults.map((result) => result.toJson()).toList(),
      'scanType': scanType,
    };
  }

  /// Get fraud detection rate as percentage
  double get fraudRate {
    if (totalMessagesScanned == 0) return 0.0;
    return (fraudDetected / totalMessagesScanned) * 100;
  }

  /// Get safety score (inverse of fraud rate)
  double get safetyScore {
    return 100.0 - fraudRate;
  }

  /// Format scan date for UI
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(scanDate);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${scanDate.day}/${scanDate.month}/${scanDate.year}';
    }
  }

  /// Get scan type display name
  String get scanTypeDisplay {
    switch (scanType) {
      case 'manual':
        return 'Manual Scan';
      case 'background':
        return 'Background Monitor';
      case 'scheduled':
        return 'Scheduled Scan';
      default:
        return 'SMS Scan';
    }
  }

  /// Get risk level based on fraud rate
  FraudRiskLevel get overallRiskLevel {
    if (fraudRate >= 50) return FraudRiskLevel.critical;
    if (fraudRate >= 25) return FraudRiskLevel.high;
    if (fraudRate >= 10) return FraudRiskLevel.medium;
    return FraudRiskLevel.low;
  }

  /// Get high-risk fraud results
  List<FraudResult> get highRiskFrauds {
    return fraudResults
        .where(
          (result) =>
              result.isFraud &&
              (result.riskLevel == FraudRiskLevel.high ||
                  result.riskLevel == FraudRiskLevel.critical),
        )
        .toList();
  }
}
