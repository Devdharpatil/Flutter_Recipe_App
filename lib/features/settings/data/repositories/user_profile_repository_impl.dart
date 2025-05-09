import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';

/// Implementation of the user profile repository
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile?>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final userProfile = await remoteDataSource.getUserProfile();
        return Right(userProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updateUserProfile(
          displayName: displayName,
          avatarUrl: avatarUrl,
        );
        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> getUserPreferences() async {
    if (await networkInfo.isConnected) {
      try {
        final preferences = await remoteDataSource.getUserPreferences();
        return Right(preferences);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> updateUserPreferences({
    required List<String> dietaryPrefs,
    required List<String> cookingGoals,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedPreferences = await remoteDataSource.updateUserPreferences(
          dietaryPrefs: dietaryPrefs,
          cookingGoals: cookingGoals,
        );
        return Right(updatedPreferences);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AppSettings>> getAppSettings() async {
    if (await networkInfo.isConnected) {
      try {
        final settings = await remoteDataSource.getAppSettings();
        return Right(settings);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AppSettings>> updateAppSettings({
    required String themePreference,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedSettings = await remoteDataSource.updateAppSettings(
          themePreference: themePreference,
        );
        return Right(updatedSettings);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
} 