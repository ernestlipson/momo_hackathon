import 'package:get/get.dart';
import '../data/services/network/base_network_service.dart';
import '../data/models/api_response.dart';

/// Example service demonstrating how to use BaseNetworkService
class ExampleApiService extends GetxService {
  late final BaseNetworkService _networkService;

  @override
  void onInit() {
    super.onInit();
    _networkService = Get.find<BaseNetworkService>();
  }

  /// Example: Login user
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'phoneNumber': phoneNumber, 'pin': pin},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Login failed: $e', statusCode: 500);
    }
  }

  /// Example: Get transaction history
  Future<ApiResponse<List<Map<String, dynamic>>>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _networkService.get<List<Map<String, dynamic>>>(
        '/transactions',
        queryParameters: {'page': page, 'limit': limit},
        fromJson: (data) {
          if (data is List) {
            return data.cast<Map<String, dynamic>>();
          }
          return <Map<String, dynamic>>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch transactions: $e',
        statusCode: 500,
      );
    }
  }

  /// Example: Submit transaction for fraud analysis
  Future<ApiResponse<Map<String, dynamic>>> analyzeTransaction({
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        '/fraud/analyze',
        data: transactionData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Fraud analysis failed: $e',
        statusCode: 500,
      );
    }
  }

  /// Example: Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>(
        '/user/profile',
        data: profileData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Profile update failed: $e',
        statusCode: 500,
      );
    }
  }

  /// Example: Delete user account
  Future<ApiResponse<bool>> deleteAccount() async {
    try {
      final response = await _networkService.delete<bool>(
        '/user/account',
        fromJson: (data) => data == true,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Account deletion failed: $e',
        statusCode: 500,
      );
    }
  }
}

/// Example controller showing how to use the API service
class ExampleController extends GetxController {
  late final ExampleApiService _apiService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final transactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ExampleApiService>();
  }

  /// Example: Handle login
  Future<void> handleLogin(String phoneNumber, String pin) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.login(
        phoneNumber: phoneNumber,
        pin: pin,
      );

      if (response.success) {
        // Handle successful login
        Get.snackbar('Success', 'Login successful');
        // Navigate to home or dashboard
      } else {
        errorMessage.value = response.message;
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  /// Example: Load transaction history
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.getTransactionHistory(
        page: 1,
        limit: 50,
      );

      if (response.success && response.data != null) {
        transactions.value = response.data!;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load transactions';
    } finally {
      isLoading.value = false;
    }
  }

  /// Example: Analyze suspicious transaction
  Future<void> analyzeTransaction(Map<String, dynamic> transaction) async {
    try {
      isLoading.value = true;

      final response = await _apiService.analyzeTransaction(
        transactionData: transaction,
      );

      if (response.success) {
        final analysisResult = response.data;
        if (analysisResult?['isFraudulent'] == true) {
          Get.snackbar(
            'Fraud Alert',
            'This transaction has been flagged as potentially fraudulent',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        } else {
          Get.snackbar('Safe', 'Transaction appears to be legitimate');
        }
      } else {
        Get.snackbar('Error', 'Analysis failed: ${response.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to analyze transaction');
    } finally {
      isLoading.value = false;
    }
  }
}
