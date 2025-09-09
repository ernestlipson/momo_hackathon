import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:momo_hackathon/app/data/models/fraud_detection_stats.dart';
import 'package:momo_hackathon/app/data/models/network_exception.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
import 'package:momo_hackathon/app/data/services/network/base_network_service.dart';
import 'package:momo_hackathon/app/data/models/api_response.dart';

/// Mock classes for testing
class MockBaseNetworkService extends Mock implements BaseNetworkService {}

void main() {
  group('FraudDetectionService Tests', () {
    late FraudDetectionService fraudService;
    late MockBaseNetworkService mockNetworkService;

    setUp(() {
      mockNetworkService = MockBaseNetworkService();

      // Setup GetX
      Get.testMode = true;
      Get.put<BaseNetworkService>(mockNetworkService);

      fraudService = FraudDetectionService();
    });

    tearDown(() {
      Get.reset();
    });

    group('getStatsOverview', () {
      test(
        'should return fraud detection statistics on successful API call',
        () async {
          // Arrange
          final mockStatsData = {
            'totalAnalyses': 150,
            'fraudDetected': 12,
            'fraudRate': 8.0,
            'userScanCount': 100,
            'backgroundScanCount': 50,
            'textAnalysisCount': 120,
            'imageAnalysisCount': 30,
            'averageConfidence': 85.5,
            'lastAnalysisAt': '2024-01-15T10:30:00Z',
          };

          final mockResponse = ApiResponse<Map<String, dynamic>>.success(
            data: mockStatsData,
            message: 'Statistics retrieved successfully',
          );

          when(
            () => mockNetworkService.get<Map<String, dynamic>>(
              '/fraud-detection/stats/overview',
              fromJson: any(named: 'fromJson'),
            ),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await fraudService.getStatsOverview();

          // Assert
          expect(result.totalAnalyses, equals(150));
          expect(result.fraudDetected, equals(12));
          expect(result.fraudRate, equals(8.0));
          expect(result.userScanCount, equals(100));
          expect(result.backgroundScanCount, equals(50));
          expect(result.textAnalysisCount, equals(120));
          expect(result.imageAnalysisCount, equals(30));
          expect(result.averageConfidence, equals(85.5));
          expect(result.lastAnalysisAt, isNotNull);

          // Verify network call was made correctly
          verify(
            () => mockNetworkService.get<Map<String, dynamic>>(
              '/fraud-detection/stats/overview',
              fromJson: any(named: 'fromJson'),
            ),
          ).called(1);
        },
      );

      test(
        'should throw ServerException when API returns error response',
        () async {
          // Arrange
          final mockResponse = ApiResponse<Map<String, dynamic>>.error(
            message: 'Internal server error',
            statusCode: 500,
          );

          when(
            () => mockNetworkService.get<Map<String, dynamic>>(
              '/fraud-detection/stats/overview',
              fromJson: any(named: 'fromJson'),
            ),
          ).thenAnswer((_) async => mockResponse);

          // Act & Assert
          expect(
            () async => await fraudService.getStatsOverview(),
            throwsA(isA<ServerException>()),
          );
        },
      );

      test('should rethrow NetworkException from network service', () async {
        // Arrange
        when(
          () => mockNetworkService.get<Map<String, dynamic>>(
            '/fraud-detection/stats/overview',
            fromJson: any(named: 'fromJson'),
          ),
        ).thenThrow(
          const ConnectionException(message: 'No internet connection'),
        );

        // Act & Assert
        expect(
          () async => await fraudService.getStatsOverview(),
          throwsA(isA<ConnectionException>()),
        );
      });

      test('should throw ServerException for unexpected errors', () async {
        // Arrange
        when(
          () => mockNetworkService.get<Map<String, dynamic>>(
            '/fraud-detection/stats/overview',
            fromJson: any(named: 'fromJson'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () async => await fraudService.getStatsOverview(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('refreshStatsOverview', () {
      test('should return refreshed fraud detection statistics', () async {
        // Arrange
        final mockStatsData = {
          'totalAnalyses': 175,
          'fraudDetected': 15,
          'fraudRate': 8.6,
          'userScanCount': 120,
          'backgroundScanCount': 55,
          'textAnalysisCount': 140,
          'imageAnalysisCount': 35,
          'averageConfidence': 87.2,
          'lastAnalysisAt': '2024-01-15T11:30:00Z',
        };

        final mockResponse = ApiResponse<Map<String, dynamic>>.success(
          data: mockStatsData,
        );

        when(
          () => mockNetworkService.get<Map<String, dynamic>>(
            '/fraud-detection/stats/overview',
            queryParameters: any(named: 'queryParameters'),
            fromJson: any(named: 'fromJson'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await fraudService.refreshStatsOverview();

        // Assert
        expect(result.totalAnalyses, equals(175));
        expect(result.fraudDetected, equals(15));
        expect(result.fraudRate, equals(8.6));

        // Verify network call was made with refresh parameter
        verify(
          () => mockNetworkService.get<Map<String, dynamic>>(
            '/fraud-detection/stats/overview',
            queryParameters: any(named: 'queryParameters'),
            fromJson: any(named: 'fromJson'),
          ),
        ).called(1);
      });
    });

    group('getStatsForPeriod', () {
      test(
        'should return period-specific fraud detection statistics',
        () async {
          // Arrange
          final mockStatsData = {
            'totalAnalyses': 80,
            'fraudDetected': 6,
            'fraudRate': 7.5,
            'userScanCount': 60,
            'backgroundScanCount': 20,
            'textAnalysisCount': 70,
            'imageAnalysisCount': 10,
            'averageConfidence': 83.0,
            'lastAnalysisAt': '2024-01-15T09:30:00Z',
          };

          final mockResponse = ApiResponse<Map<String, dynamic>>.success(
            data: mockStatsData,
          );

          when(
            () => mockNetworkService.get<Map<String, dynamic>>(
              '/fraud-detection/stats/period',
              queryParameters: any(named: 'queryParameters'),
              fromJson: any(named: 'fromJson'),
            ),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await fraudService.getStatsForPeriod(
            '7d',
            includeDetails: true,
          );

          // Assert
          expect(result.totalAnalyses, equals(80));
          expect(result.fraudDetected, equals(6));
          expect(result.fraudRate, equals(7.5));

          // Verify network call was made with correct parameters
          verify(
            () => mockNetworkService.get<Map<String, dynamic>>(
              '/fraud-detection/stats/period',
              queryParameters: {'period': '7d', 'includeDetails': 'true'},
              fromJson: any(named: 'fromJson'),
            ),
          ).called(1);
        },
      );

      test('should handle period request without includeDetails', () async {
        // Arrange
        final mockStatsData = {
          'totalAnalyses': 50,
          'fraudDetected': 3,
          'fraudRate': 6.0,
          'userScanCount': 40,
          'backgroundScanCount': 10,
          'textAnalysisCount': 45,
          'imageAnalysisCount': 5,
          'averageConfidence': 80.0,
        };

        final mockResponse = ApiResponse<Map<String, dynamic>>.success(
          data: mockStatsData,
        );

        when(
          () => mockNetworkService.get<Map<String, dynamic>>(
            '/fraud-detection/stats/period',
            queryParameters: any(named: 'queryParameters'),
            fromJson: any(named: 'fromJson'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await fraudService.getStatsForPeriod('30d');

        // Assert
        expect(result.totalAnalyses, equals(50));
        expect(result.fraudDetected, equals(3));

        // Verify network call was made with only period parameter
        verify(
          () => mockNetworkService.get<Map<String, dynamic>>(
            '/fraud-detection/stats/period',
            queryParameters: {'period': '30d'},
            fromJson: any(named: 'fromJson'),
          ),
        ).called(1);
      });
    });
  });

  group('FraudDetectionStats Model Tests', () {
    test('should create FraudDetectionStats from JSON correctly', () {
      // Arrange
      final json = {
        'totalAnalyses': 100,
        'fraudDetected': 8,
        'fraudRate': 8.0,
        'userScanCount': 70,
        'backgroundScanCount': 30,
        'textAnalysisCount': 85,
        'imageAnalysisCount': 15,
        'averageConfidence': 82.5,
        'lastAnalysisAt': '2024-01-15T10:30:00Z',
      };

      // Act
      final stats = FraudDetectionStats.fromJson(json);

      // Assert
      expect(stats.totalAnalyses, equals(100));
      expect(stats.fraudDetected, equals(8));
      expect(stats.fraudRate, equals(8.0));
      expect(stats.userScanCount, equals(70));
      expect(stats.backgroundScanCount, equals(30));
      expect(stats.textAnalysisCount, equals(85));
      expect(stats.imageAnalysisCount, equals(15));
      expect(stats.averageConfidence, equals(82.5));
      expect(stats.lastAnalysisAt, isNotNull);
    });

    test('should handle missing JSON fields with defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final stats = FraudDetectionStats.fromJson(json);

      // Assert
      expect(stats.totalAnalyses, equals(0));
      expect(stats.fraudDetected, equals(0));
      expect(stats.fraudRate, equals(0.0));
      expect(stats.userScanCount, equals(0));
      expect(stats.backgroundScanCount, equals(0));
      expect(stats.textAnalysisCount, equals(0));
      expect(stats.imageAnalysisCount, equals(0));
      expect(stats.averageConfidence, equals(0.0));
      expect(stats.lastAnalysisAt, isNull);
    });

    test('should calculate amount saved correctly', () {
      // Arrange
      const stats = FraudDetectionStats(
        totalAnalyses: 100,
        fraudDetected: 10,
        fraudRate: 10.0,
        userScanCount: 70,
        backgroundScanCount: 30,
        textAnalysisCount: 85,
        imageAnalysisCount: 15,
        averageConfidence: 85.0,
      );

      // Act & Assert
      expect(stats.amountSaved, equals(1000.0)); // 10 * 100 = 1000
    });

    test('should identify high fraud activity correctly', () {
      // Arrange
      const highFraudStats = FraudDetectionStats(
        totalAnalyses: 100,
        fraudDetected: 35,
        fraudRate: 35.0, // > 30%
        userScanCount: 70,
        backgroundScanCount: 30,
        textAnalysisCount: 85,
        imageAnalysisCount: 15,
        averageConfidence: 85.0,
      );

      const lowFraudStats = FraudDetectionStats(
        totalAnalyses: 100,
        fraudDetected: 5,
        fraudRate: 5.0, // < 30%
        userScanCount: 70,
        backgroundScanCount: 30,
        textAnalysisCount: 85,
        imageAnalysisCount: 15,
        averageConfidence: 85.0,
      );

      // Act & Assert
      expect(highFraudStats.hasHighFraudActivity, isTrue);
      expect(lowFraudStats.hasHighFraudActivity, isFalse);
    });

    test('should identify good confidence levels correctly', () {
      // Arrange
      const goodConfidenceStats = FraudDetectionStats(
        totalAnalyses: 100,
        fraudDetected: 10,
        fraudRate: 10.0,
        userScanCount: 70,
        backgroundScanCount: 30,
        textAnalysisCount: 85,
        imageAnalysisCount: 15,
        averageConfidence: 85.0, // >= 80%
      );

      const poorConfidenceStats = FraudDetectionStats(
        totalAnalyses: 100,
        fraudDetected: 10,
        fraudRate: 10.0,
        userScanCount: 70,
        backgroundScanCount: 30,
        textAnalysisCount: 85,
        imageAnalysisCount: 15,
        averageConfidence: 75.0, // < 80%
      );

      // Act & Assert
      expect(goodConfidenceStats.hasGoodConfidence, isTrue);
      expect(poorConfidenceStats.hasGoodConfidence, isFalse);
    });

    test('should format display strings correctly', () {
      // Arrange
      const stats = FraudDetectionStats(
        totalAnalyses: 100,
        fraudDetected: 10,
        fraudRate: 8.5,
        userScanCount: 70,
        backgroundScanCount: 30,
        textAnalysisCount: 85,
        imageAnalysisCount: 15,
        averageConfidence: 82.3,
      );

      // Act & Assert
      expect(stats.fraudRateDisplay, equals('8.5%'));
      expect(stats.confidenceDisplay, equals('82.3%'));
    });

    test('should create empty stats correctly', () {
      // Act
      final emptyStats = FraudDetectionStats.empty();

      // Assert
      expect(emptyStats.totalAnalyses, equals(0));
      expect(emptyStats.fraudDetected, equals(0));
      expect(emptyStats.fraudRate, equals(0.0));
      expect(emptyStats.averageConfidence, equals(0.0));
      expect(emptyStats.lastAnalysisAt, isNull);
    });
  });
}
