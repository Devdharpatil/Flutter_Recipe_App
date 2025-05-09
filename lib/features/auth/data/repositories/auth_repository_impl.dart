import 'dart:math' as math;
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart' as local;

class AuthRepositoryImpl implements AuthRepository {
  final local.AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfile = await remoteDataSource.login(
          email: email,
          password: password,
        );
        return Right(userProfile);
      } on local.AuthException catch (e) {
        return Left(_mapAuthExceptionToFailure(e));
      } catch (e) {
        return Left(ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signUp({
    required String displayName,
    required String email,
    required String password,
    bool receiveUpdates = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfile = await remoteDataSource.signUp(
          displayName: displayName,
          email: email,
          password: password,
          receiveUpdates: receiveUpdates,
        );
        return Right(userProfile);
      } on local.AuthException catch (e) {
        return Left(_mapAuthExceptionToFailure(e));
      } catch (e) {
        return Left(ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resetPassword(email: email);
        return const Right(null);
      } on local.AuthException catch (e) {
        return Left(_mapAuthExceptionToFailure(e));
      } catch (e) {
        return Left(ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.signOut();
        return const Right(null);
      } on local.AuthException catch (e) {
        return Left(_mapAuthExceptionToFailure(e));
      } catch (e) {
        return Left(ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }
  
  /// Maps an AuthException to the appropriate Failure type
  Failure _mapAuthExceptionToFailure(local.AuthException e) {
    // Check the error code or message to determine the appropriate failure type
    final code = e.code;
    final message = e.message;
    
    if (code == 'invalid_credentials' || message.contains('Invalid login credentials')) {
      return const InvalidCredentialsFailure();
    } else if (code == 'user_not_found' || message.contains('User not found')) {
      return const UserNotFoundFailure();
    } else if (message.contains('already registered') || message.contains('already in use')) {
      return const EmailInUseFailure();
    } else if (message.contains('weak password') || message.contains('password is too weak')) {
      return WeakPasswordFailure(message);
    } else {
      return ServerFailure(message: message);
    }
  }
} 