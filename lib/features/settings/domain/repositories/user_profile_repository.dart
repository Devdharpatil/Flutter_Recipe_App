import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../entities/app_settings.dart';
import '../entities/user_preferences.dart';

/// Repository interface for user profile operations
abstract class UserProfileRepository {
  /// Get the current user's profile
  Future<Either<Failure, UserProfile?>> getUserProfile();
  
  /// Update the user's profile
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  });
  
  /// Get the user's preferences
  Future<Either<Failure, UserPreferences>> getUserPreferences();
  
  /// Update the user's preferences
  Future<Either<Failure, UserPreferences>> updateUserPreferences({
    required List<String> dietaryPrefs,
    required List<String> cookingGoals,
  });
  
  /// Get the app settings
  Future<Either<Failure, AppSettings>> getAppSettings();
  
  /// Update the app settings
  Future<Either<Failure, AppSettings>> updateAppSettings({
    required String themePreference,
  });
} 