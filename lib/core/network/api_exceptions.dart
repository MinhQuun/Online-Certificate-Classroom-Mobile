class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {int? statusCode})
    : super(statusCode: statusCode ?? 401);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}
