import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../local_auth_db_service.dart';

class BaseNetworkService extends GetxService {
  static const String baseUrl = 'https://f0c17w6f-8000.uks1.devtunnels.ms/api';
  late final Dio _dio;

  @override
  void onInit() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    super.onInit();
  }

  Future<Response?> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final token = LocalAuthDbService.getAuthToken();
      final options = Options(
        headers: {'Authorization': token != null ? 'Bearer $token' : ''},
      );
      return await _dio.get(path, queryParameters: query, options: options);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Response?> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final token = LocalAuthDbService.getAuthToken();
      final options = Options(
        headers: {'Authorization': token != null ? 'Bearer $token' : ''},
      );
      return await _dio.post(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Response?> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final token = LocalAuthDbService.getAuthToken();
      final options = Options(
        headers: {'Authorization': token != null ? 'Bearer $token' : ''},
      );
      return await _dio.put(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Response?> delete(String path, {Map<String, dynamic>? query}) async {
    try {
      final token = LocalAuthDbService.getAuthToken();
      final options = Options(
        headers: {'Authorization': token != null ? 'Bearer $token' : ''},
      );
      return await _dio.delete(path, queryParameters: query, options: options);
    } catch (e) {
      return _handleError(e);
    }
  }

  Response? _handleError(dynamic error) {
    if (error is DioException) {
      return error.response;
    }
    return null;
  }
}
