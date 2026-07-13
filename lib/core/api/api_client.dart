import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    // The base URL can be passed at compile time using:
    // --dart-define=API_BASE_URL=http://your-ip:3000
    baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Singleton pattern
  ApiClient._();
  static final instance = ApiClient._();
  
  Dio get dio => _dio;
}
