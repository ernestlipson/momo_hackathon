/// Model for fraud detection statistics overview
class FraudDetectionStats {
  final int totalAnalyses;
  final int fraudDetected;
  final double fraudRate;
  final int userScanCount;
  final int backgroundScanCount;
  final int textAnalysisCount;
  final int imageAnalysisCount;
  final double averageConfidence;
  final DateTime? lastAnalysisAt;

  const FraudDetectionStats({
    required this.totalAnalyses,
    required this.fraudDetected,
    required this.fraudRate,
    required this.userScanCount,
    required this.backgroundScanCount,
    required this.textAnalysisCount,
    required this.imageAnalysisCount,
    required this.averageConfidence,
    this.lastAnalysisAt,
  });

  /// Factory constructor from JSON
  factory FraudDetectionStats.fromJson(Map<String, dynamic> json) {
    return FraudDetectionStats(
      totalAnalyses: json['totalAnalyses'] ?? 0,
      fraudDetected: json['fraudDetected'] ?? 0,
      fraudRate: (json['fraudRate'] ?? 0.0).toDouble(),
      userScanCount: json['userScanCount'] ?? 0,
      backgroundScanCount: json['backgroundScanCount'] ?? 0,
      textAnalysisCount: json['textAnalysisCount'] ?? 0,
      imageAnalysisCount: json['imageAnalysisCount'] ?? 0,
      averageConfidence: (json['averageConfidence'] ?? 0.0).toDouble(),
      lastAnalysisAt: json['lastAnalysisAt'] != null
          ? DateTime.tryParse(json['lastAnalysisAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalAnalyses': totalAnalyses,
      'fraudDetected': fraudDetected,
      'fraudRate': fraudRate,
      'userScanCount': userScanCount,
      'backgroundScanCount': backgroundScanCount,
      'textAnalysisCount': textAnalysisCount,
      'imageAnalysisCount': imageAnalysisCount,
      'averageConfidence': averageConfidence,
      'lastAnalysisAt': lastAnalysisAt?.toIso8601String(),
    };
  }

  /// Calculate amount saved based on fraud detected
  /// Assuming average transaction amount of 100 GHS
  double get amountSaved {
    const double averageTransactionAmount = 100.0;
    return fraudDetected * averageTransactionAmount;
  }

  /// Get fraud detection rate as percentage string
  String get fraudRateDisplay {
    return '${fraudRate.toStringAsFixed(1)}%';
  }

  /// Get average confidence as percentage string
  String get confidenceDisplay {
    return '${averageConfidence.toStringAsFixed(1)}%';
  }

  /// Check if statistics show high fraud activity
  bool get hasHighFraudActivity {
    return fraudRate > 30.0; // More than 30% fraud rate
  }

  /// Check if confidence level is acceptable
  bool get hasGoodConfidence {
    return averageConfidence >= 80.0; // At least 80% confidence
  }

  /// Get formatted last analysis time
  String get lastAnalysisDisplay {
    if (lastAnalysisAt == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastAnalysisAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create empty stats for initial state
  factory FraudDetectionStats.empty() {
    return const FraudDetectionStats(
      totalAnalyses: 0,
      fraudDetected: 0,
      fraudRate: 0.0,
      userScanCount: 0,
      backgroundScanCount: 0,
      textAnalysisCount: 0,
      imageAnalysisCount: 0,
      averageConfidence: 0.0,
      lastAnalysisAt: null,
    );
  }

  /// Copy with new values
  FraudDetectionStats copyWith({
    int? totalAnalyses,
    int? fraudDetected,
    double? fraudRate,
    int? userScanCount,
    int? backgroundScanCount,
    int? textAnalysisCount,
    int? imageAnalysisCount,
    double? averageConfidence,
    DateTime? lastAnalysisAt,
  }) {
    return FraudDetectionStats(
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      fraudDetected: fraudDetected ?? this.fraudDetected,
      fraudRate: fraudRate ?? this.fraudRate,
      userScanCount: userScanCount ?? this.userScanCount,
      backgroundScanCount: backgroundScanCount ?? this.backgroundScanCount,
      textAnalysisCount: textAnalysisCount ?? this.textAnalysisCount,
      imageAnalysisCount: imageAnalysisCount ?? this.imageAnalysisCount,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      lastAnalysisAt: lastAnalysisAt ?? this.lastAnalysisAt,
    );
  }

  @override
  String toString() {
    return 'FraudDetectionStats{'
        'totalAnalyses: $totalAnalyses, '
        'fraudDetected: $fraudDetected, '
        'fraudRate: $fraudRate, '
        'userScanCount: $userScanCount, '
        'backgroundScanCount: $backgroundScanCount, '
        'textAnalysisCount: $textAnalysisCount, '
        'imageAnalysisCount: $imageAnalysisCount, '
        'averageConfidence: $averageConfidence, '
        'lastAnalysisAt: $lastAnalysisAt'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FraudDetectionStats &&
        other.totalAnalyses == totalAnalyses &&
        other.fraudDetected == fraudDetected &&
        other.fraudRate == fraudRate &&
        other.userScanCount == userScanCount &&
        other.backgroundScanCount == backgroundScanCount &&
        other.textAnalysisCount == textAnalysisCount &&
        other.imageAnalysisCount == imageAnalysisCount &&
        other.averageConfidence == averageConfidence &&
        other.lastAnalysisAt == lastAnalysisAt;
  }

  @override
  int get hashCode {
    return totalAnalyses.hashCode ^
        fraudDetected.hashCode ^
        fraudRate.hashCode ^
        userScanCount.hashCode ^
        backgroundScanCount.hashCode ^
        textAnalysisCount.hashCode ^
        imageAnalysisCount.hashCode ^
        averageConfidence.hashCode ^
        lastAnalysisAt.hashCode;
  }
}
