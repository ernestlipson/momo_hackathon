import 'package:intl/intl.dart';

/// Model for recent fraud analysis from API
class RecentAnalysis {
  final String id;
  final String analysisId;
  final String status;
  final int confidence;
  final String source;
  final String analysisType;
  final DateTime createdAt;
  final List<String> riskFactors;

  const RecentAnalysis({
    required this.id,
    required this.analysisId,
    required this.status,
    required this.confidence,
    required this.source,
    required this.analysisType,
    required this.createdAt,
    required this.riskFactors,
  });

  /// Create from JSON
  factory RecentAnalysis.fromJson(Map<String, dynamic> json) {
    return RecentAnalysis(
      id: json['id'] ?? '',
      analysisId: json['analysisId'] ?? '',
      status: json['status'] ?? '',
      confidence: json['confidence'] ?? 0,
      source: json['source'] ?? '',
      analysisType: json['analysisType'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analysisId': analysisId,
      'status': status,
      'confidence': confidence,
      'source': source,
      'analysisType': analysisType,
      'createdAt': createdAt.toIso8601String(),
      'riskFactors': riskFactors,
    };
  }

  /// Check if analysis is fraud
  bool get isFraud => status.toUpperCase() == 'FRAUD';

  /// Get formatted date for display
  String get formattedDate {
    return DateFormat('MMM d, yyyy • h:mm a').format(createdAt);
  }

  /// Get status display text
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'FRAUD':
        return 'Fraud Detected';
      case 'LEGITIMATE':
        return 'Legitimate';
      case 'SUSPICIOUS':
        return 'Suspicious';
      default:
        return 'Unknown';
    }
  }

  /// Get source display text
  String get sourceDisplay {
    switch (source.toUpperCase()) {
      case 'USER_SCAN':
        return 'Manual Scan';
      case 'BACKGROUND_SCAN':
        return 'Background';
      case 'SCHEDULED_SCAN':
        return 'Scheduled';
      default:
        return source;
    }
  }

  /// Get analysis type display text
  String get typeDisplay {
    switch (analysisType.toUpperCase()) {
      case 'TEXT':
        return 'SMS Text';
      case 'IMAGE':
        return 'Image';
      case 'VOICE':
        return 'Voice';
      default:
        return analysisType;
    }
  }

  /// Get confidence percentage
  String get confidenceDisplay => '$confidence%';

  /// Get risk level based on confidence
  String get riskLevel {
    if (confidence >= 90) return 'High Risk';
    if (confidence >= 70) return 'Medium Risk';
    if (confidence >= 50) return 'Low Risk';
    return 'Very Low Risk';
  }
}

/// Response wrapper for recent analyses
class RecentAnalysesResponse {
  final List<RecentAnalysis> analyses;
  final int total;

  const RecentAnalysesResponse({required this.analyses, required this.total});

  /// Create from JSON
  factory RecentAnalysesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final analysesList = data['analyses'] as List? ?? [];

    return RecentAnalysesResponse(
      analyses: analysesList
          .map(
            (analysis) =>
                RecentAnalysis.fromJson(analysis as Map<String, dynamic>),
          )
          .toList(),
      total: data['total'] ?? 0,
    );
  }
}
