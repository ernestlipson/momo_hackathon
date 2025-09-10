import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../models/api_response.dart';
import '../../models/network_exception.dart';
import '../storage/secure_storage_service.dart';
import 'dart:io';
import 'dart:developer' as developer;

/// Base network service for all API requests
class BaseNetworkService extends getx.GetxService {
  static const String baseUrl = 'https://f0c17w6f-8000.uks1.devtunnels.ms/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  late final Dio _dio;
  late final SecureStorageService _storageService;

  // Request queue for offline scenarios
  final List<QueuedRequest> _requestQueue = [];
  final bool _isOnline = true;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeService();
  }

  /// Initialize the network service
  Future<void> _initializeService() async {
    _storageService = SecureStorageService();
    await _storageService.init();

    // Configure Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _addInterceptors();
  }

  /// Add security and logging interceptors
  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _onRequest(options, handler);
        },
        onResponse: (response, handler) {
          _onResponse(response, handler);
        },
        onError: (error, handler) {
          _onError(error, handler);
        },
      ),
    );

    // Logging interceptor for development
    const bool isDebugMode = !bool.fromEnvironment('dart.vm.product');
    if (isDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) =>
              developer.log(obj.toString(), name: 'NetworkService'),
        ),
      );
    }
  }

  /// Handle outgoing requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Add authentication token
      final token = _storageService.getAuthToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Failed to prepare request: $e',
        ),
      );
    }
  }

  /// Handle incoming responses
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful responses for fraud analysis
    _logRequestMetrics(response.requestOptions, response.statusCode, null);
    handler.next(response);
  }

  /// Handle request errors
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    // Convert to custom exceptions
    final networkException = NetworkExceptionHandler.handleDioError(error);

    // Log error for fraud analysis
    _logRequestMetrics(
      error.requestOptions,
      error.response?.statusCode,
      networkException,
    );

    // Handle token expiration
    if (networkException is AuthenticationException &&
        networkException.errorCode == 'TOKEN_EXPIRED') {
      _handleTokenExpiration();
    }
    handler.reject(error);
  }

  /// Log request metrics for fraud detection
  void _logRequestMetrics(
    RequestOptions options,
    int? statusCode,
    NetworkException? error,
  ) {
    final metrics = {
      'url': options.uri.toString(),
      'method': options.method,
      'statusCode': statusCode,
      'duration':
          DateTime.now().millisecondsSinceEpoch -
          int.parse(options.headers['X-Request-Time'] ?? '0'),
      'error': error?.toString(),
      'deviceId': options.headers['X-Device-ID'],
      'timestamp': DateTime.now().toIso8601String(),
    };

    developer.log('Request Metrics: $metrics', name: 'FraudDetection');
  }

  /// Handle token expiration
  Future<void> _handleTokenExpiration() async {
    try {
      final refreshToken = _storageService.getRefreshToken();
      if (refreshToken != null) {
        // Attempt to refresh token
        await _refreshAuthToken(refreshToken);
      } else {
        // Redirect to login
        await _storageService.clearAuthData();
        getx.Get.offAllNamed('/login');
      }
    } catch (e) {
      await _storageService.clearAuthData();
      getx.Get.offAllNamed('/login');
    }
  }

  /// Refresh authentication token
  Future<void> _refreshAuthToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storageService.storeAuthToken(data['token']);
        await _storageService.storeRefreshToken(data['refreshToken']);
      }
    } catch (e) {
      throw AuthenticationException.tokenExpired();
    }
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      return ApiResponse.fromJson(
        response.data,
        fromJson,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final networkException = NetworkExceptionHandler.handleDioError(e);
      return ApiResponse.error(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 500,
        errorCode: networkException.errorCode,
      );
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(
        response.data,
        fromJson,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final networkException = NetworkExceptionHandler.handleDioError(e);
      return ApiResponse.error(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 500,
        errorCode: networkException.errorCode,
      );
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(
        response.data,
        fromJson,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final networkException = NetworkExceptionHandler.handleDioError(e);
      return ApiResponse.error(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 500,
        errorCode: networkException.errorCode,
      );
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(
        response.data,
        fromJson,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final networkException = NetworkExceptionHandler.handleDioError(e);
      return ApiResponse.error(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 500,
        errorCode: networkException.errorCode,
      );
    }
  }

  /// Upload file with progress tracking
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData();

      // Add file
      formData.files.add(
        MapEntry(fieldName, await MultipartFile.fromFile(file.path)),
      );

      // Add additional data
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );

      return ApiResponse.fromJson(
        response.data,
        fromJson,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final networkException = NetworkExceptionHandler.handleDioError(e);
      return ApiResponse.error(
        message: networkException.message,
        statusCode: networkException.statusCode ?? 500,
        errorCode: networkException.errorCode,
      );
    }
  }

  /// Get current network status
  bool get isOnline => _isOnline;

  /// Get queued requests count
  int get queuedRequestsCount => _requestQueue.length;

  /// Clear all queued requests
  void clearRequestQueue() {
    _requestQueue.clear();
  }
}

/// Queued request model for offline scenarios
class QueuedRequest {
  final RequestOptions options;
  final DateTime timestamp;

  QueuedRequest({required this.options, required this.timestamp});
}
