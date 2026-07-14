import '../errors/failure.dart';
import '../errors/exception.dart';

String formatError(Object error) {
  if (error is Failure) return error.message;
  if (error is ServerException) return error.message;
  if (error is CacheException) return error.message;

  final errorStr = error.toString();
  if (errorStr.contains('DioException [connection error]') ||
      errorStr.contains('SocketException') ||
      errorStr.contains('XMLHttpRequest error')) {
    return 'Network connection lost. Please check your internet or server.';
  }
  
  // Basic cleanup
  return errorStr.replaceAll('Exception: ', '');
}
