import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

// --- Base Failure Class ---
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object?> get props => [];
}

// --- Specific Failure Types ---
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({String message = 'Server Error Occurred', this.statusCode}) : super(message);
  
  @override 
  List<Object> get props => [message, statusCode ?? 'null'];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Error Occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network Connection Error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Input Validation Failed']);
}

class ApiException extends Failure {
  final int? statusCode;
  const ApiException({required String message, this.statusCode}) : super(message);
  
  @override 
  List<Object> get props => [message, statusCode ?? 'null'];
}

// Resource not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found'}) : super(message);
}

// Auth-specific failures
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid email or password']);
}

class EmailInUseFailure extends Failure {
  const EmailInUseFailure([super.message = 'Email is already in use']);
}

class AuthFailure extends Failure {
  const AuthFailure({String message = 'Authentication failed'}) : super(message);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

// --- Either Extensions ---
extension EitherX<L, R> on Either<L, R> {
  R getRightOrThrow() {
    return fold(
      (l) => throw Exception('Tried to getRight from a Left: $l'),
      (r) => r,
    );
  }

  L getLeftOrThrow() {
    return fold(
      (l) => l,
      (r) => throw Exception('Tried to getLeft from a Right: $r'),
    );
  }

  // For direct use in UI builders, mapping state to widget
  Widget when({
    required Widget Function(L failure) failure,
    required Widget Function(R data) success,
  }) {
    return fold(
      (l) => failure(l),
      (r) => success(r),
    );
  }

  // Functional chaining (bind/flatMap)
  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return fold(
      (l) => Left(l),
      (r) => f(r),
    );
  }
} 