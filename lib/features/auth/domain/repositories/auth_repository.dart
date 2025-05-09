import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  });

  /// Sign up a new user
  Future<Either<Failure, UserProfile>> signUp({
    required String displayName,
    required String email,
    required String password,
    bool receiveUpdates = false,
  });

  /// Send a password reset email
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Check if the user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();
} 