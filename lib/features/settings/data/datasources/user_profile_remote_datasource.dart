import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/user_preferences.dart';
import '../models/app_settings_model.dart';
import '../models/user_preferences_model.dart';
import '../../../../core/error/exceptions.dart';

/// Interface for user profile remote data source
abstract class UserProfileRemoteDataSource {
  /// Get the current user's profile
  Future<UserProfile?> getUserProfile();
  
  /// Update the user's profile
  Future<UserProfile> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  });
  
  /// Get the user's preferences
  Future<UserPreferences> getUserPreferences();
  
  /// Update the user's preferences
  Future<UserPreferences> updateUserPreferences({
    required List<String> dietaryPrefs,
    required List<String> cookingGoals,
  });
  
  /// Get the app settings
  Future<AppSettings> getAppSettings();
  
  /// Update the app settings
  Future<AppSettings> updateAppSettings({
    required String themePreference,
  });
}

/// Implementation of user profile remote data source using Supabase
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserProfileRemoteDataSourceImpl({required this.supabaseClient});

  /// Check if profile exists for current user, create if not exists
  Future<void> _ensureProfileExists() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException(message: 'No authenticated user found');
    }

    // Check if profile exists
    final response = await supabaseClient
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    // Create profile if it doesn't exist
    if (response == null) {
      final userMeta = supabaseClient.auth.currentUser?.userMetadata;
      final email = supabaseClient.auth.currentUser?.email ?? '';
      String displayName = 'User';
      
      if (userMeta != null && userMeta.containsKey('full_name')) {
        displayName = userMeta['full_name'] as String;
      } else if (email.isNotEmpty) {
        displayName = email.split('@').first;
      }
      
      await supabaseClient
          .from('user_profiles')
          .insert({
            'user_id': userId,
            'display_name': displayName,
            'email': email,
            'dietary_prefs': [],
            'cooking_goals': [],
            'theme_preference': 'system',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
    }
  }

  /// Upload a new profile image to storage
  Future<String?> _uploadProfileImage(String filePath) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw ServerException(message: 'File does not exist');
      }

      final fileExt = filePath.split('.').last;
      final fileName = 'profile_$userId.$fileExt';
      final path = 'profiles/$fileName';

      await supabaseClient.storage
          .from('user_avatars')
          .upload(path, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      final imageUrl = supabaseClient.storage
          .from('user_avatars')
          .getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      throw ServerException(message: 'Failed to upload profile image: ${e.toString()}');
    }
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      await _ensureProfileExists();

      final response = await supabaseClient
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserProfile> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      await _ensureProfileExists();

      // Handle profile image upload if provided
      String? uploadedImageUrl;
      if (avatarUrl != null) {
        uploadedImageUrl = await _uploadProfileImage(avatarUrl);
      }

      final updateData = {
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add avatar URL to update data if available
      if (uploadedImageUrl != null) {
        updateData['avatar_url'] = uploadedImageUrl;
      }

      final response = await supabaseClient
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserPreferences> getUserPreferences() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      await _ensureProfileExists();

      final response = await supabaseClient
          .from('user_profiles')
          .select('dietary_prefs, cooking_goals')
          .eq('user_id', userId)
          .single();
      
      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to get user preferences: ${e.toString()}');
    }
  }

  @override
  Future<UserPreferences> updateUserPreferences({
    required List<String> dietaryPrefs,
    required List<String> cookingGoals,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      await _ensureProfileExists();

      final response = await supabaseClient
          .from('user_profiles')
          .update({
            'dietary_prefs': dietaryPrefs,
            'cooking_goals': cookingGoals,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select('dietary_prefs, cooking_goals')
          .single();

      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update user preferences: ${e.toString()}');
    }
  }

  @override
  Future<AppSettings> getAppSettings() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      await _ensureProfileExists();

      final response = await supabaseClient
          .from('user_profiles')
          .select('theme_preference')
          .eq('user_id', userId)
          .single();
      
      return AppSettingsModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to get app settings: ${e.toString()}');
    }
  }

  @override
  Future<AppSettings> updateAppSettings({
    required String themePreference,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'No authenticated user found');
      }

      await _ensureProfileExists();

      final response = await supabaseClient
          .from('user_profiles')
          .update({
            'theme_preference': themePreference,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select('theme_preference')
          .single();

      return AppSettingsModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update app settings: ${e.toString()}');
    }
  }
} 