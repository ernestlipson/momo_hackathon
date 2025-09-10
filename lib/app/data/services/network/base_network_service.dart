import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class BaseNetworkService extends GetxService {
  static const String baseUrl = 'https://f0c17w6f-8000.uks1.devtunnels.ms/api';
  static const String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtZmQ3aW1wOTAwMDA4bzRiMmcydTFkMGIiLCJlbWFpbCI6ImVybmVzdGxpcHNvbkBnbWFpbC5jb20iLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc1NzU0MTA2OSwiZXhwIjoxNzU3NjI3NDY5fQ.4YaE7njRSWuwUkE5OkB4LnnHDEn0prL_8bRuPhul_bU';

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
          'Authorization': 'Bearer $token',
        },
      ),
    );
    super.onInit();
  }

  Future<Response?> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
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
      return await _dio.post(path, data: data, queryParameters: query);
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
      return await _dio.put(path, data: data, queryParameters: query);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Response?> delete(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.delete(path, queryParameters: query);
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
