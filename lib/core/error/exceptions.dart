/// Base class for all exceptions
class AppException implements Exception {
  final String message;
  
  AppException({this.message = 'An unknown error occurred'});
  
  @override
  String toString() => 'AppException: $message';
}

/// Exception for server/API errors
class ServerException extends AppException {
  final int? statusCode;
  
  ServerException({super.message = 'Server error', this.statusCode});
  
  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception for local data source/cache errors
class CacheException extends AppException {
  CacheException({super.message = 'Cache error'});
  
  @override
  String toString() => 'CacheException: $message';
}

/// Exception for network connectivity issues
class NetworkException extends AppException {
  NetworkException({super.message = 'Network error'});
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for authentication errors
class AuthException extends AppException {
  AuthException({super.message = 'Authentication error'});
  
  @override
  String toString() => 'AuthException: $message';
}

/// Exception for unauthorized access
class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'Unauthorized'});
  
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception for resource not found (404)
class NotFoundException extends AppException {
  NotFoundException({super.message = 'Resource not found'});
  
  @override
  String toString() => 'NotFoundException: $message';
} 
 