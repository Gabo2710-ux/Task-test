String formatError(Object error) {
  final errorStr = error.toString();
  if (errorStr.contains('DioException [connection error]') ||
      errorStr.contains('SocketException') ||
      errorStr.contains('XMLHttpRequest error')) {
    return 'Network connection lost. Please check your internet or server.';
  }
  
  // Basic cleanup
  return errorStr.replaceAll('Exception: ', '');
}
