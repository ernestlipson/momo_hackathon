import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:momo_hackathon/app/data/models/sms_message.dart';
import 'package:momo_hackathon/app/data/models/fraud_result.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
import 'package:momo_hackathon/app/data/services/network/base_network_service.dart';

class MockNetworkService extends Mock implements BaseNetworkService {}

void main() {
  group('Fraud Detection Service Tests', () {
    late FraudDetectionService fraudService;
    late MockNetworkService mockNetworkService;

    setUp(() {
      mockNetworkService = MockNetworkService();
      Get.put<BaseNetworkService>(mockNetworkService);
      fraudService = FraudDetectionService();
    });

    tearDown(() {
      Get.reset();
    });

    group('SMS Message Classification', () {
      test('should identify mobile money transaction messages', () {
        final legitimateMessage = SmsMessage(
          id: '1',
          sender: 'MTN',
          body: 'You have received GHS 50.00 from 0244123456. Your balance is GHS 150.00. Ref: MM123456789',
          timestamp: DateTime.now(),
        );

        expect(legitimateMessage.isMobileMoneyTransaction, true);
      });

      test('should filter out non-mobile money messages', () {
        final regularMessage = SmsMessage(
          id: '1',
          sender: 'Friend',
          body: 'Hey, how are you doing today?',
          timestamp: DateTime.now(),
        );

        expect(regularMessage.isMobileMoneyTransaction, false);
      });
    });

    group('Local Fraud Analysis', () {
      test('should detect phishing keywords in SMS', () async {
        final phishingMessage = SmsMessage(
          id: '1',
          sender: 'UNKNOWN',
          body: 'URGENT: Your account has been suspended. Click here to verify your account immediately or you will lose your money!',
          timestamp: DateTime.now(),
        );

        final result = await fraudService.analyzeSmsMessage(phishingMessage);

        expect(result.isFraud, true);
        expect(result.riskLevel, FraudRiskLevel.high);
        expect(result.redFlags, contains('Contains phishing keywords'));
        expect(result.redFlags, contains('Uses urgent/threatening language'));
        expect(result.confidenceScore, greaterThan(0.5));
      });

      test('should detect social engineering tactics', () async {
        final socialEngineeringMessage = SmsMessage(
          id: '1',
          sender: 'FAKE-MTN',
          body: 'Congratulations! You have won GHS 10,000 in our lottery! To claim your prize, send your PIN to this number immediately!',
          timestamp: DateTime.now(),
        );

        final result = await fraudService.analyzeSmsMessage(socialEngineeringMessage);

        expect(result.isFraud, true);
        expect(result.redFlags, contains('Social engineering tactics detected'));
        expect(result.fraudType, FraudType.socialEngineering);
      });

      test('should identify legitimate mobile money messages as safe', () async {
        final legitimateMessage = SmsMessage(
          id: '1',
          sender: 'MTN',
          body: 'You have successfully sent GHS 25.00 to 0201987654. Your new balance is GHS 75.50. Transaction ID: VF987654321',
          timestamp: DateTime.now(),
        );

        final result = await fraudService.analyzeSmsMessage(legitimateMessage);

        expect(result.isFraud, false);
        expect(result.riskLevel, FraudRiskLevel.low);
        expect(result.confidenceScore, lessThan(0.5));
      });

      test('should detect suspicious links in SMS', () async {
        final linkMessage = SmsMessage(
          id: '1',
          sender: 'SCAMMER',
          body: 'Your account will be blocked! Visit bit.ly/fake-link to prevent this.',
          timestamp: DateTime.now(),
        );

        final result = await fraudService.analyzeSmsMessage(linkMessage);

        expect(result.isFraud, true);
        expect(result.redFlags, contains('Contains suspicious links'));
        expect(result.fraudType, FraudType.phishing);
      });

      test('should detect sender impersonation', () async {
        final impersonationMessage = SmsMessage(
          id: '1',
          sender: 'MTN-BANK', // Fake sender trying to impersonate MTN
          body: 'Your MTN mobile money account needs verification. Send your PIN to complete verification.',
          timestamp: DateTime.now(),
        );

        final result = await fraudService.analyzeSmsMessage(impersonationMessage);

        expect(result.isFraud, true);
        expect(result.redFlags, contains('Suspicious sender'));
      });
    });

    group('Fraud Statistics', () {
      test('should calculate fraud statistics correctly', () {
        final fraudResults = [
          FraudResult(
            messageId: '1',
            isFraud: true,
            confidenceScore: 0.8,
            riskLevel: FraudRiskLevel.high,
            analyzedAt: DateTime.now(),
          ),
          FraudResult(
            messageId: '2',
            isFraud: false,
            confidenceScore: 0.2,
            riskLevel: FraudRiskLevel.low,
            analyzedAt: DateTime.now(),
          ),
          FraudResult(
            messageId: '3',
            isFraud: true,
            confidenceScore: 0.9,
            riskLevel: FraudRiskLevel.critical,
            analyzedAt: DateTime.now(),
          ),
        ];

        final stats = fraudService.getFraudStats(fraudResults);

        expect(stats['totalMessages'], 3);
        expect(stats['fraudMessages'], 2);
        expect(stats['fraudRate'], 66.66666666666667); // 2/3 * 100
        expect(stats['highRiskMessages'], 2); // Both high and critical
        expect(stats['averageConfidence'], closeTo(0.63, 0.01)); // (0.8 + 0.2 + 0.9) / 3
      });

      test('should handle empty results list', () {
        final stats = fraudService.getFraudStats([]);

        expect(stats['totalMessages'], 0);
        expect(stats['fraudMessages'], 0);
        expect(stats['fraudRate'], 0.0);
        expect(stats['highRiskMessages'], 0);
        expect(stats['averageConfidence'], 0.0);
        expect(stats['lastAnalyzed'], null);
      });
    });

    group('Risk Level Classification', () {
      test('should classify risk levels correctly', () {
        // This tests the private _getRiskLevel method indirectly through analyzeSmsMessage
        
        // High risk message
        final highRiskMessage = SmsMessage(
          id: '1',
          sender: 'SCAMMER',
          body: 'URGENT: Click here immediately to verify your account or lose all your money! bit.ly/scam',
          timestamp: DateTime.now(),
        );

        fraudService.analyzeSmsMessage(highRiskMessage).then((result) {
          expect(result.riskLevel, anyOf([FraudRiskLevel.high, FraudRiskLevel.critical]));
        });

        // Low risk message  
        final lowRiskMessage = SmsMessage(
          id: '2',
          sender: 'MTN',
          body: 'Transaction successful. Amount: GHS 10.00',
          timestamp: DateTime.now(),
        );

        fraudService.analyzeSmsMessage(lowRiskMessage).then((result) {
          expect(result.riskLevel, FraudRiskLevel.low);
        });
      });
    });
  });

  group('SMS Message Model Tests', () {
    test('should detect mobile money keywords correctly', () {
      final testCases = [
        {
          'message': SmsMessage(
            id: '1',
            sender: 'MTN',
            body: 'Transaction completed',
            timestamp: DateTime.now(),
          ),
          'expected': true,
        },
        {
          'message': SmsMessage(
            id: '2',
            sender: 'BANK',
            body: 'Your balance is GHS 100.00',
            timestamp: DateTime.now(),
          ),
          'expected': true,
        },
        {
          'message': SmsMessage(
            id: '3',
            sender: 'Friend',
            body: 'Hello, how are you?',
            timestamp: DateTime.now(),
          ),
          'expected': false,
        },
        {
          'message': SmsMessage(
            id: '4',
            sender: 'VODAFONE',
            body: 'Payment received from 024XXXXXXX',
            timestamp: DateTime.now(),
          ),
          'expected': true,
        },
      ];

      for (final testCase in testCases) {
        final message = testCase['message'] as SmsMessage;
        final expected = testCase['expected'] as bool;
        
        expect(
          message.isMobileMoneyTransaction, 
          expected,
          reason: 'Message "${message.body}" should be ${expected ? "detected" : "ignored"}',
        );
      }
    });

    test('should serialize and deserialize correctly', () {
      final originalMessage = SmsMessage(
        id: '123',
        sender: 'MTN',
        body: 'Test message body',
        timestamp: DateTime.parse('2024-01-15T14:35:00.000Z'),
        address: '024XXXXXXX',
      );

      final json = originalMessage.toJson();
      final deserializedMessage = SmsMessage.fromJson(json);

      expect(deserializedMessage.id, originalMessage.id);
      expect(deserializedMessage.sender, originalMessage.sender);
      expect(deserializedMessage.body, originalMessage.body);
      expect(deserializedMessage.timestamp, originalMessage.timestamp);
      expect(deserializedMessage.address, originalMessage.address);
    });
  });
}