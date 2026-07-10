import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    // Reemplaza con la IP de tu máquina si usas un emulador Android (ej. 10.0.2.2)
    // O usa localhost si estás corriendo en web/windows
    baseUrl: 'http://localhost:3000',
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
