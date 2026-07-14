abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'A server failure occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'A cache failure occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'A network failure occurred']) : super(message);
}
