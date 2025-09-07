enum FraudRiskLevel { low, medium, high, critical }

enum FraudType {
  phishing,
  socialEngineering,
  simSwap,
  unauthorizedTransfer,
  spoofing,
  unknown,
}

class FraudResult {
  final String messageId;
  final bool isFraud;
  final double confidenceScore; // 0.0 to 1.0
  final FraudRiskLevel riskLevel;
  final FraudType? fraudType;
  final String? reason;
  final List<String> redFlags;
  final DateTime analyzedAt;
  final Map<String, dynamic>? additionalData;

  FraudResult({
    required this.messageId,
    required this.isFraud,
    required this.confidenceScore,
    required this.riskLevel,
    this.fraudType,
    this.reason,
    this.redFlags = const [],
    required this.analyzedAt,
    this.additionalData,
  });

  factory FraudResult.fromJson(Map<String, dynamic> json) {
    return FraudResult(
      messageId: json['messageId'] ?? '',
      isFraud: json['isFraud'] ?? false,
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      riskLevel: FraudRiskLevel.values.firstWhere(
        (level) => level.name == json['riskLevel'],
        orElse: () => FraudRiskLevel.low,
      ),
      fraudType: json['fraudType'] != null
          ? FraudType.values.firstWhere(
              (type) => type.name == json['fraudType'],
              orElse: () => FraudType.unknown,
            )
          : null,
      reason: json['reason'],
      redFlags: List<String>.from(json['redFlags'] ?? []),
      analyzedAt: DateTime.parse(
        json['analyzedAt'] ?? DateTime.now().toIso8601String(),
      ),
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'isFraud': isFraud,
      'confidenceScore': confidenceScore,
      'riskLevel': riskLevel.name,
      'fraudType': fraudType?.name,
      'reason': reason,
      'redFlags': redFlags,
      'analyzedAt': analyzedAt.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  String get riskLevelText {
    switch (riskLevel) {
      case FraudRiskLevel.low:
        return 'Low Risk';
      case FraudRiskLevel.medium:
        return 'Medium Risk';
      case FraudRiskLevel.high:
        return 'High Risk';
      case FraudRiskLevel.critical:
        return 'Critical Risk';
    }
  }

  String get fraudTypeText {
    switch (fraudType) {
      case FraudType.phishing:
        return 'Phishing Attack';
      case FraudType.socialEngineering:
        return 'Social Engineering';
      case FraudType.simSwap:
        return 'SIM Swap Attack';
      case FraudType.unauthorizedTransfer:
        return 'Unauthorized Transfer';
      case FraudType.spoofing:
        return 'Sender Spoofing';
      case FraudType.unknown:
        return 'Unknown Fraud Type';
      case null:
        return 'Not Fraud';
    }
  }

  @override
  String toString() {
    return 'FraudResult(messageId: $messageId, isFraud: $isFraud, riskLevel: $riskLevel, confidenceScore: $confidenceScore)';
  }
}
