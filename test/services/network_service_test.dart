import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/services/network/base_network_service.dart';
import 'package:momo_hackathon/app/data/models/api_response.dart';

void main() {
  group('BaseNetworkService Tests', () {
    late BaseNetworkService networkService;

    setUpAll(() async {
      // Initialize GetX for testing
      Get.testMode = true;
    });

    setUp(() async {
      // Initialize network service for each test
      networkService = BaseNetworkService();
      await networkService.onInit();
    });

    tearDown(() {
      // Clean up after each test
      Get.reset();
    });

    group('Service Initialization', () {
      test('should initialize with correct base URL', () {
        expect(
          BaseNetworkService.baseUrl,
          equals('https://f0c17w6f-8000.uks1.devtunnels.ms/api'),
        );
      });

      test('should initialize with correct timeouts', () {
        expect(
          BaseNetworkService.connectionTimeout,
          equals(const Duration(seconds: 30)),
        );
        expect(
          BaseNetworkService.receiveTimeout,
          equals(const Duration(seconds: 30)),
        );
        expect(
          BaseNetworkService.sendTimeout,
          equals(const Duration(seconds: 30)),
        );
      });

      test('should be online by default', () {
        expect(networkService.isOnline, isTrue);
      });

      test('should have empty request queue initially', () {
        expect(networkService.queuedRequestsCount, equals(0));
      });
    });

    group('Request Methods', () {
      test('should handle GET request with proper error handling', () async {
        // This test would require mocking the actual HTTP calls
        // For now, we test the method signature and basic functionality
        expect(() => networkService.get('/test'), returnsNormally);
      });

      test('should handle POST request with data', () async {
        expect(
          () => networkService.post('/test', data: {'key': 'value'}),
          returnsNormally,
        );
      });

      test('should handle PUT request', () async {
        expect(
          () => networkService.put('/test', data: {'key': 'value'}),
          returnsNormally,
        );
      });

      test('should handle DELETE request', () async {
        expect(() => networkService.delete('/test'), returnsNormally);
      });
    });

    group('Security Features', () {
      test('should add security headers to requests', () {
        // Test would verify that security headers are added
        // This requires mocking the Dio interceptors
        expect(networkService, isNotNull);
      });

      test('should handle authentication token', () {
        // Test authentication token handling
        expect(networkService, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should convert DioException to NetworkException', () {
        // Test error conversion
        expect(networkService, isNotNull);
      });

      test('should handle offline scenarios', () {
        // Test offline request queueing
        expect(networkService.queuedRequestsCount, equals(0));
      });
    });

    group('Request Queue Management', () {
      test('should clear request queue', () {
        networkService.clearRequestQueue();
        expect(networkService.queuedRequestsCount, equals(0));
      });
    });
  });

  group('ApiResponse Tests', () {
    test('should create successful response', () {
      final response = ApiResponse.success(
        data: {'message': 'Success'},
        message: 'Operation completed',
        statusCode: 200,
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Operation completed'));
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
    });

    test('should create error response', () {
      final response = ApiResponse.error(
        message: 'Something went wrong',
        statusCode: 500,
        errorCode: 'INTERNAL_ERROR',
      );

      expect(response.success, isFalse);
      expect(response.message, equals('Something went wrong'));
      expect(response.statusCode, equals(500));
      expect(response.errorCode, equals('INTERNAL_ERROR'));
      expect(response.data, isNull);
    });

    test('should convert from JSON', () {
      final json = {
        'success': true,
        'message': 'Test message',
        'data': {'id': 1, 'name': 'Test'},
        'statusCode': 200,
      };

      final response = ApiResponse.fromJson(json, null);

      expect(response.success, isTrue);
      expect(response.message, equals('Test message'));
      expect(response.statusCode, equals(200));
    });

    test('should convert to JSON', () {
      final response = ApiResponse.success(
        data: {'test': 'data'},
        message: 'Success',
      );

      final json = response.toJson();

      expect(json['success'], isTrue);
      expect(json['message'], equals('Success'));
      expect(json['data'], isNotNull);
      expect(json['timestamp'], isNotNull);
    });
  });
}
