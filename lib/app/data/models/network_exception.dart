import 'package:dio/dio.dart';

/// Base network exception for all network-related errors
abstract class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic originalError;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'NetworkException: $message (Code: $statusCode)';
  }
}

/// Connection-related exceptions
class ConnectionException extends NetworkException {
  const ConnectionException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });

  factory ConnectionException.noInternet() {
    return const ConnectionException(
      message: 'No internet connection available',
      statusCode: 0,
      errorCode: 'NO_INTERNET',
    );
  }

  factory ConnectionException.timeout() {
    return const ConnectionException(
      message: 'Connection timeout',
      statusCode: 408,
      errorCode: 'TIMEOUT',
    );
  }
}

/// Server-related exceptions
class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });

  factory ServerException.internalError() {
    return const ServerException(
      message: 'Internal server error',
      statusCode: 500,
      errorCode: 'INTERNAL_ERROR',
    );
  }

  factory ServerException.serviceUnavailable() {
    return const ServerException(
      message: 'Service temporarily unavailable',
      statusCode: 503,
      errorCode: 'SERVICE_UNAVAILABLE',
    );
  }
}

/// Authentication-related exceptions
class AuthenticationException extends NetworkException {
  const AuthenticationException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });

  factory AuthenticationException.unauthorized() {
    return const AuthenticationException(
      message: 'Authentication required',
      statusCode: 401,
      errorCode: 'UNAUTHORIZED',
    );
  }

  factory AuthenticationException.forbidden() {
    return const AuthenticationException(
      message: 'Access forbidden',
      statusCode: 403,
      errorCode: 'FORBIDDEN',
    );
  }

  factory AuthenticationException.tokenExpired() {
    return const AuthenticationException(
      message: 'Authentication token expired',
      statusCode: 401,
      errorCode: 'TOKEN_EXPIRED',
    );
  }
}

/// Validation-related exceptions
class ValidationException extends NetworkException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
    this.fieldErrors,
  });

  factory ValidationException.badRequest({
    required String message,
    Map<String, List<String>>? fieldErrors,
  }) {
    return ValidationException(
      message: message,
      statusCode: 400,
      errorCode: 'BAD_REQUEST',
      fieldErrors: fieldErrors,
    );
  }
}

/// Rate limiting exceptions
class RateLimitException extends NetworkException {
  final Duration? retryAfter;

  const RateLimitException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
    this.retryAfter,
  });

  factory RateLimitException.tooManyRequests({Duration? retryAfter}) {
    return RateLimitException(
      message: 'Too many requests. Please try again later.',
      statusCode: 429,
      errorCode: 'RATE_LIMIT_EXCEEDED',
      retryAfter: retryAfter,
    );
  }
}

/// Security-related exceptions specific to fraud detection
class SecurityException extends NetworkException {
  const SecurityException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });

  factory SecurityException.suspiciousActivity() {
    return const SecurityException(
      message: 'Suspicious activity detected',
      statusCode: 403,
      errorCode: 'SUSPICIOUS_ACTIVITY',
    );
  }

  factory SecurityException.certificateError() {
    return const SecurityException(
      message: 'SSL certificate verification failed',
      statusCode: 0,
      errorCode: 'CERTIFICATE_ERROR',
    );
  }
}

/// Utility class to convert Dio errors to custom exceptions
class NetworkExceptionHandler {
  static NetworkException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionException.timeout();

      case DioExceptionType.badCertificate:
        return SecurityException.certificateError();

      case DioExceptionType.connectionError:
        return ConnectionException.noInternet();

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return const ConnectionException(
          message: 'Request was cancelled',
          errorCode: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.unknown:
        return _NetworkExceptionImpl(
          message: 'Unknown network error: ${error.message}',
          originalError: error,
        );
    }
  }

  static NetworkException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return ValidationException.badRequest(
          message: data?['message'] ?? 'Bad request',
          fieldErrors: data?['fieldErrors'],
        );

      case 401:
        return AuthenticationException.unauthorized();

      case 403:
        return AuthenticationException.forbidden();

      case 429:
        final retryAfter = error.response?.headers['retry-after']?.first;
        return RateLimitException.tooManyRequests(
          retryAfter: retryAfter != null
              ? Duration(seconds: int.tryParse(retryAfter) ?? 60)
              : null,
        );

      case 500:
        return ServerException.internalError();

      case 503:
        return ServerException.serviceUnavailable();

      default:
        return ServerException(
          message: data?['message'] ?? 'Server error',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }
}

class _NetworkExceptionImpl extends NetworkException {
  const _NetworkExceptionImpl({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.originalError,
  });
}
