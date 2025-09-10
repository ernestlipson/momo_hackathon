import 'package:get/get.dart';
import '../models/fraud_detection_stats.dart';
import '../models/network_exception.dart';
import '../models/sms_message.dart';
import '../models/fraud_result.dart';
import '../models/recent_analysis.dart';
import 'network/base_network_service.dart';

class FraudDetectionService extends GetxService {
  final BaseNetworkService _networkService = Get.find<BaseNetworkService>();

  /// Get fraud detection statistics overview for authenticated user
  ///
  /// This endpoint provides comprehensive statistics about fraud detection
  /// activities including total analyses, fraud detection rates, and
  /// analysis type breakdowns.
  ///
  /// Returns [FraudDetectionStats] with current statistics
  /// Throws [NetworkException] on network errors
  Future<FraudDetectionStats> getStatsOverview() async {
    try {
      // Make authenticated request to stats endpoint
      final response = await _networkService.get<Map<String, dynamic>>(
        '/fraud-detection/stats/overview',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      // Handle successful response
      if (response.success && response.data != null) {
        return FraudDetectionStats.fromJson(response.data!);
      }

      // Handle API error response
      throw ServerException(
        message:
            'Failed to load fraud detection statistics: ${response.message}',
        statusCode: response.statusCode ?? 500,
      );
    } on NetworkException {
      // Re-throw network exceptions as-is
      rethrow;
    } catch (e) {
      // Handle unexpected errors
      throw ServerException(
        message: 'Unexpected error loading statistics: ${e.toString()}',
      );
    }
  }

  /// Refresh fraud detection statistics with cache bypass
  Future<FraudDetectionStats> refreshStatsOverview() async {
    try {
      // For refresh, we'll make the same call
      // In a real implementation, you might add cache-busting query parameters
      final response = await _networkService.get<Map<String, dynamic>>(
        '/fraud-detection/stats/overview',
        queryParameters: {
          'refresh': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return FraudDetectionStats.fromJson(response.data!);
      }

      throw ServerException(
        message:
            'Failed to refresh fraud detection statistics: ${response.message}',
        statusCode: response.statusCode ?? 500,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error refreshing statistics: ${e.toString()}',
      );
    }
  }

  /// Get recent fraud analyses for the authenticated user
  ///
  /// This endpoint provides a list of recent fraud detection analyses
  /// performed by the user, including their status, confidence, and metadata.
  ///
  /// Returns [RecentAnalysesResponse] with recent analyses and total count
  /// Throws [NetworkException] on network errors
  Future<RecentAnalysesResponse> getRecentAnalyses({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      // Make authenticated request to recent analyses endpoint
      final response = await _networkService.get<Map<String, dynamic>>(
        '/fraud-detection/stats/recent',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      // Handle successful response
      if (response.success && response.data != null) {
        return RecentAnalysesResponse.fromJson(response.data!);
      }

      // Handle API error response
      throw ServerException(
        message: 'Failed to load recent analyses: ${response.message}',
        statusCode: response.statusCode ?? 500,
      );
    } on NetworkException {
      // Re-throw network exceptions as-is
      rethrow;
    } catch (e) {
      // Handle unexpected errors
      throw ServerException(
        message: 'Unexpected error loading recent analyses: ${e.toString()}',
      );
    }
  }

  /// Get detailed fraud detection statistics for a specific time period
  ///
  /// [period] - Time period ('7d', '30d', '90d', '1y')
  /// [includeDetails] - Whether to include detailed breakdown
  ///
  /// Returns [FraudDetectionStats] for the specified period
  Future<FraudDetectionStats> getStatsForPeriod(
    String period, {
    bool includeDetails = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        if (includeDetails) 'includeDetails': 'true',
      };

      final response = await _networkService.get<Map<String, dynamic>>(
        '/fraud-detection/stats/period',
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return FraudDetectionStats.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to load period statistics: ${response.message}',
        statusCode: response.statusCode ?? 500,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error loading period statistics: ${e.toString()}',
      );
    }
  }

  /// Analyze SMS message for fraud using AWS Nova (via your NestJS backend)
  Future<FraudResult> analyzeSmsMessage(SmsMessage message) async {
    try {
      // For demo purposes, we'll use local analysis
      // In production, this would call your NestJS API with AWS Nova
      return await _analyzeLocally(message);

      // Production implementation would be:
      // return await _analyzeWithApi(message);
    } catch (e) {
      print('Error analyzing message: $e');
      // Return safe result on error
      return FraudResult(
        messageId: message.id,
        isFraud: false,
        confidenceScore: 0.0,
        riskLevel: FraudRiskLevel.low,
        reason: 'Analysis failed: $e',
        analyzedAt: DateTime.now(),
      );
    }
  }

  /// Local fraud analysis (for demo/offline use)
  Future<FraudResult> _analyzeLocally(SmsMessage message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final analysis = _performLocalAnalysis(message);

    return FraudResult(
      messageId: message.id,
      isFraud: analysis['isFraud'],
      confidenceScore: analysis['confidence'],
      riskLevel: analysis['riskLevel'],
      fraudType: analysis['fraudType'],
      reason: analysis['reason'],
      redFlags: analysis['redFlags'],
      analyzedAt: DateTime.now(),
      additionalData: {
        'analysisMethod': 'local',
        'sender': message.sender,
        'messageLength': message.body.length,
      },
    );
  }

  /// Real API analysis (production implementation)
  /// Uncomment when ready to integrate with actual API
  /* 
  Future<FraudResult> _analyzeWithApi(SmsMessage message) async {
    try {
      final response = await _dio.post(
        '/fraud/analyze',
        data: {
          'message': message.toJson(),
          'analysisType': 'sms',
          'language': 'en', // Could be dynamic based on user settings
        },
      );

      return FraudResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please check your API credentials.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
  */

  /// Local fraud detection logic
  Map<String, dynamic> _performLocalAnalysis(SmsMessage message) {
    final List<String> redFlags = [];
    double riskScore = 0.0;
    FraudType? fraudType;
    String? reason;

    final body = message.body.toLowerCase();
    final sender = message.sender.toUpperCase();

    // Check for phishing indicators
    if (_containsPhishingKeywords(body)) {
      redFlags.add('Contains phishing keywords');
      riskScore += 0.4;
      fraudType = FraudType.phishing;
    }

    // Check for urgent language
    if (_containsUrgentLanguage(body)) {
      redFlags.add('Uses urgent/threatening language');
      riskScore += 0.3;
    }

    // Check for suspicious URLs or links
    if (_containsSuspiciousLinks(body)) {
      redFlags.add('Contains suspicious links');
      riskScore += 0.5;
      fraudType = FraudType.phishing;
    }

    // Check for social engineering tactics
    if (_containsSocialEngineering(body)) {
      redFlags.add('Social engineering tactics detected');
      riskScore += 0.4;
      fraudType = FraudType.socialEngineering;
    }

    // Check sender authenticity
    if (_isSuspiciousSender(sender)) {
      redFlags.add('Suspicious sender');
      riskScore += 0.3;
      fraudType = FraudType.spoofing;
    }

    // Check for unusual transaction amounts
    if (_hasUnusualAmounts(body)) {
      redFlags.add('Unusual transaction amounts');
      riskScore += 0.2;
    }

    // Determine risk level and fraud status
    final bool isFraud = riskScore >= 0.5;
    final FraudRiskLevel riskLevel = _getRiskLevel(riskScore);

    if (isFraud) {
      reason = 'Multiple fraud indicators detected: ${redFlags.join(', ')}';
    } else if (riskScore > 0.2) {
      reason = 'Some suspicious elements found but below fraud threshold';
    } else {
      reason = 'Message appears legitimate';
    }

    return {
      'isFraud': isFraud,
      'confidence': riskScore.clamp(0.0, 1.0),
      'riskLevel': riskLevel,
      'fraudType': fraudType,
      'reason': reason,
      'redFlags': redFlags,
    };
  }

  bool _containsPhishingKeywords(String text) {
    final phishingKeywords = [
      'verify account',
      'click here',
      'urgent action',
      'suspended',
      'confirm identity',
      'update information',
      'security alert',
      'unauthorized access',
      'immediate attention',
      'temporary block',
    ];

    return phishingKeywords.any((keyword) => text.contains(keyword));
  }

  bool _containsUrgentLanguage(String text) {
    final urgentKeywords = [
      'urgent',
      'immediate',
      'expire',
      'within 24 hours',
      'act now',
      'limited time',
      'deadline',
      'asap',
      'emergency',
    ];

    return urgentKeywords.any((keyword) => text.contains(keyword));
  }

  bool _containsSuspiciousLinks(String text) {
    final suspiciousPatterns = [
      RegExp(r'bit\.ly'),
      RegExp(r'tinyurl'),
      RegExp(r'[a-z0-9]+\.tk'),
      RegExp(r'[a-z0-9]+\.ml'),
      RegExp(r'http://[^/]*[0-9]+\.[0-9]+'), // IP addresses
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(text));
  }

  bool _containsSocialEngineering(String text) {
    final socialEngineeringKeywords = [
      'congratulations',
      'you have won',
      'lottery',
      'prize',
      'free money',
      'claim now',
      'lucky winner',
      'inheritance',
      'beneficiary',
    ];

    return socialEngineeringKeywords.any((keyword) => text.contains(keyword));
  }

  bool _isSuspiciousSender(String sender) {
    // Check if sender looks like it's impersonating legitimate services
    final legitimateServices = ['MTN', 'VODAFONE', 'AIRTELTIGO', 'TELECEL'];
    final suspiciousPatterns = [
      RegExp(r'^[0-9]+$'), // Only numbers
      RegExp(r'[0-9]{10,}'), // Very long numbers
    ];

    // Check for fake service names
    for (String service in legitimateServices) {
      if (sender.contains(service) && sender != service) {
        return true; // e.g., "MTN-BANK" when legitimate is just "MTN"
      }
    }

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(sender));
  }

  bool _hasUnusualAmounts(String text) {
    final amountPattern = RegExp(
      r'(ghs|cedis|₵)\s*([0-9,]+\.?[0-9]*)',
      caseSensitive: false,
    );
    final matches = amountPattern.allMatches(text);

    for (Match match in matches) {
      final amountStr = match.group(2)?.replaceAll(',', '') ?? '0';
      final amount = double.tryParse(amountStr) ?? 0;

      // Flag unusually high amounts (could indicate fraud)
      if (amount > 10000) {
        return true;
      }
    }

    return false;
  }

  FraudRiskLevel _getRiskLevel(double score) {
    if (score >= 0.8) return FraudRiskLevel.critical;
    if (score >= 0.6) return FraudRiskLevel.high;
    if (score >= 0.3) return FraudRiskLevel.medium;
    return FraudRiskLevel.low;
  }

  /// Batch analyze multiple messages
  Future<List<FraudResult>> analyzeMessages(List<SmsMessage> messages) async {
    final List<FraudResult> results = [];

    for (SmsMessage message in messages) {
      final result = await analyzeSmsMessage(message);
      results.add(result);
    }

    return results;
  }

  /// Get fraud statistics
  Map<String, dynamic> getFraudStats(List<FraudResult> results) {
    final totalMessages = results.length;
    final fraudMessages = results.where((r) => r.isFraud).length;
    final highRiskMessages = results
        .where(
          (r) =>
              r.riskLevel == FraudRiskLevel.high ||
              r.riskLevel == FraudRiskLevel.critical,
        )
        .length;

    final avgConfidence = results.isNotEmpty
        ? results.map((r) => r.confidenceScore).reduce((a, b) => a + b) /
              results.length
        : 0.0;

    return {
      'totalMessages': totalMessages,
      'fraudMessages': fraudMessages,
      'fraudRate': totalMessages > 0
          ? (fraudMessages / totalMessages) * 100
          : 0.0,
      'highRiskMessages': highRiskMessages,
      'averageConfidence': avgConfidence,
      'lastAnalyzed': results.isNotEmpty ? results.last.analyzedAt : null,
    };
  }
}
