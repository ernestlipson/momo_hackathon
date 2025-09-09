# Base Network Service

A secure, feature-rich network service implementation for the Ghana Mobile Money Fraud Detection Platform.

## Features

### ✅ Security First

- **Authentication**: Automatic Bearer token handling
- **Request Signing**: HMAC-based request signatures
- **Device Fingerprinting**: Unique device identification for fraud detection
- **Certificate Pinning**: SSL/TLS security (planned)
- **Secure Storage**: Encrypted token storage using get_storage

### ✅ Fraud Detection Ready

- **Request Metrics**: Comprehensive logging for fraud analysis
- **Device Tracking**: X-Device-ID headers for anomaly detection
- **Timestamp Validation**: Request timing for security
- **Anomaly Detection**: Network behavior monitoring

### ✅ Mobile Optimized

- **Offline Support**: Request queueing for offline scenarios
- **Retry Logic**: Exponential backoff for failed requests
- **Connection Monitoring**: Network connectivity awareness
- **Performance**: Optimized for mobile network conditions

### ✅ Developer Experience

- **Type Safety**: Generic API responses with proper typing
- **Error Handling**: Comprehensive exception hierarchy
- **Logging**: Detailed request/response logging in debug mode
- **Testing**: Unit test coverage with mocking support

## Quick Start

### 1. Service Initialization

The network service is automatically initialized through GetX dependency injection:

```dart
// Services are bound in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InitialBindings().dependencies();
  
  runApp(GetMaterialApp(
    initialBinding: ServiceBindings(),
    // ... other config
  ));
}
```

### 2. Basic Usage

```dart
class UserService extends GetxService {
  late final BaseNetworkService _networkService;

  @override
  void onInit() {
    _networkService = Get.find<BaseNetworkService>();
  }

  Future<ApiResponse<User>> getUser(String userId) async {
    return await _networkService.get<User>(
      '/users/$userId',
      fromJson: (data) => User.fromJson(data),
    );
  }
}
```

### 3. POST Request with Data

```dart
Future<ApiResponse<AuthResponse>> login(String phone, String pin) async {
  return await _networkService.post<AuthResponse>(
    '/auth/login',
    data: {
      'phoneNumber': phone,
      'pin': pin,
    },
    fromJson: (data) => AuthResponse.fromJson(data),
  );
}
```

### 4. File Upload

```dart
Future<ApiResponse<UploadResponse>> uploadDocument(File file) async {
  return await _networkService.uploadFile<UploadResponse>(
    '/documents/upload',
    file,
    fieldName: 'document',
    additionalData: {'category': 'identity'},
    onProgress: (sent, total) => print('Progress: ${sent/total * 100}%'),
    fromJson: (data) => UploadResponse.fromJson(data),
  );
}
```

## API Reference

### BaseNetworkService

#### Methods

- `get<T>()` - Perform GET request
- `post<T>()` - Perform POST request  
- `put<T>()` - Perform PUT request
- `delete<T>()` - Perform DELETE request
- `uploadFile<T>()` - Upload files with progress tracking

#### Properties

- `isOnline` - Current network connectivity status
- `queuedRequestsCount` - Number of queued offline requests
- `baseUrl` - API base URL

### ApiResponse<T>

Generic response wrapper for all API calls:

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final String? errorCode;
  final DateTime timestamp;
}
```

#### Factory Methods

- `ApiResponse.success()` - Create successful response
- `ApiResponse.error()` - Create error response
- `ApiResponse.fromJson()` - Parse from API response

### Exception Hierarchy

```
NetworkException (abstract)
├── ConnectionException
│   ├── noInternet()
│   └── timeout()
├── ServerException
│   ├── internalError()
│   └── serviceUnavailable()
├── AuthenticationException
│   ├── unauthorized()
│   ├── forbidden()
│   └── tokenExpired()
├── ValidationException
│   └── badRequest()
├── RateLimitException
│   └── tooManyRequests()
└── SecurityException
    ├── suspiciousActivity()
    └── certificateError()
```

## Security Features

### Authentication

Automatic token management:

- Bearer token injection in requests
- Automatic token refresh on expiration
- Secure token storage with encryption

### Request Security

Every request includes:

- `Authorization: Bearer <token>`
- `X-Device-ID: <device_fingerprint>`
- `X-Request-Time: <timestamp>`
- `X-Request-Signature: <hmac_signature>`

### Fraud Detection Headers

Custom headers for fraud analysis:

- Device identification
- Request timing
- Signature validation
- User agent tracking

## Offline Support

### Request Queueing

Failed requests are automatically queued when offline:

```dart
// Requests are queued automatically
final response = await networkService.get('/data');

// Check queue status
print('Queued requests: ${networkService.queuedRequestsCount}');

// Clear queue if needed
networkService.clearRequestQueue();
```

### Connection Monitoring

```dart
// Check connectivity
if (networkService.isOnline) {
  // Make request
} else {
  // Show offline message
}
```

## Error Handling

### Exception Handling

```dart
try {
  final response = await networkService.get('/data');
  if (response.success) {
    // Handle success
  } else {
    // Handle API error
    print('Error: ${response.message}');
  }
} on ConnectionException catch (e) {
  // Handle connection issues
  print('Connection error: ${e.message}');
} on AuthenticationException catch (e) {
  // Handle auth issues
  print('Auth error: ${e.message}');
} on NetworkException catch (e) {
  // Handle other network errors
  print('Network error: ${e.message}');
}
```

### Response Validation

```dart
final response = await networkService.get<List<Transaction>>('/transactions');

if (response.success && response.data != null) {
  final transactions = response.data!;
  // Process transactions
} else {
  // Handle error
  showError(response.message);
}
```

## Testing

### Unit Tests

```dart
void main() {
  group('NetworkService Tests', () {
    late BaseNetworkService networkService;

    setUp(() async {
      networkService = BaseNetworkService();
      await networkService.onInit();
    });

    test('should initialize correctly', () {
      expect(networkService.isOnline, isTrue);
      expect(networkService.queuedRequestsCount, equals(0));
    });
  });
}
```

### Mocking

For integration tests, mock the Dio client:

```dart
// Use mocktail or mockito to mock Dio responses
final mockDio = MockDio();
when(() => mockDio.get(any())).thenAnswer(
  (_) async => Response(
    data: {'success': true, 'data': []},
    statusCode: 200,
    requestOptions: RequestOptions(path: '/test'),
  ),
);
```

## Configuration

### Environment Variables

Configure base URL and timeouts:

```dart
class NetworkConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://f0c17w6f-8000.uks1.devtunnels.ms/api',
  );
  
  static const Duration timeout = Duration(
    seconds: int.fromEnvironment('API_TIMEOUT', defaultValue: 30),
  );
}
```

### Interceptors

Add custom interceptors:

```dart
// In BaseNetworkService._addInterceptors()
_dio.interceptors.add(CustomInterceptor());
```

## Best Practices

### 1. Always Use Typed Responses

```dart
// ✅ Good
Future<ApiResponse<User>> getUser() async {
  return networkService.get<User>('/user', fromJson: User.fromJson);
}

// ❌ Avoid
Future<ApiResponse<dynamic>> getUser() async {
  return networkService.get('/user');
}
```

### 2. Handle All Error Cases

```dart
// ✅ Good
final response = await networkService.get<User>('/user');
if (response.success) {
  return response.data!;
} else {
  throw Exception(response.message);
}

// ❌ Avoid
final response = await networkService.get<User>('/user');
return response.data!; // Might be null!
```

### 3. Use Proper Exception Handling

```dart
// ✅ Good
try {
  final response = await networkService.post('/data', data: payload);
  return response;
} on ValidationException catch (e) {
  // Handle validation errors specifically
  showValidationErrors(e.fieldErrors);
} on AuthenticationException catch (e) {
  // Handle auth errors
  redirectToLogin();
} on NetworkException catch (e) {
  // Handle other network errors
  showGenericError(e.message);
}
```

### 4. Implement Proper Loading States

```dart
class DataController extends GetxController {
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await apiService.getData();
      if (response.success) {
        // Update UI
      } else {
        error.value = response.message;
      }
    } catch (e) {
      error.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }
}
```

## Performance Tips

1. **Use connection pooling** - Dio handles this automatically
2. **Implement response caching** - For frequently accessed data
3. **Optimize request size** - Send only necessary data
4. **Use compression** - Enable gzip compression
5. **Monitor network usage** - Track data consumption

## Security Considerations

1. **Never log sensitive data** - Exclude PII from logs
2. **Implement certificate pinning** - For production apps
3. **Use proper encryption** - For stored tokens and data
4. **Validate all inputs** - Before sending to API
5. **Monitor for anomalies** - Unusual request patterns

## Troubleshooting

### Common Issues

1. **Connection timeouts** - Check network connectivity and server status
2. **Authentication failures** - Verify token validity and refresh logic
3. **SSL certificate errors** - Check certificate configuration
4. **Request queueing issues** - Monitor offline request queue

### Debug Logging

Enable detailed logging in debug mode:

```dart
// Logs are automatically enabled in debug builds
// Check the console for detailed request/response information
```

## Migration Guide

### From HTTP Package

```dart
// Old (http package)
final response = await http.get(
  Uri.parse('$baseUrl/users'),
  headers: {'Authorization': 'Bearer $token'},
);

// New (BaseNetworkService)
final response = await networkService.get<List<User>>(
  '/users',
  fromJson: (data) => (data as List).map((item) => User.fromJson(item)).toList(),
);
```

### From Raw Dio

```dart
// Old (raw Dio)
final dio = Dio();
final response = await dio.get('/users');

// New (BaseNetworkService)
final response = await networkService.get<List<User>>('/users');
```
