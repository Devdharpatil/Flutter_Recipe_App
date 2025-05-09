import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/entities/user_profile.dart';

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  
  const AuthException(this.message, {this.statusCode, this.code});
  
  factory AuthException.fromSupabaseException(dynamic e) {
    // Handle Supabase AuthException
    if (e is AuthException) {
      return AuthException(e.message, statusCode: e.statusCode, code: e.code);
    }
    
    // Parse error message from Supabase
    if (e.toString().contains('AuthApiException') || e.toString().contains('AuthException')) {
      // Extract just the message from complex exception format
      final regex = RegExp(r'message: ([^,)]+)');
      final match = regex.firstMatch(e.toString());
      final message = match?.group(1) ?? 'Authentication failed';
      
      // Extract status code if present
      final statusCodeRegex = RegExp(r'statusCode: (\d+)');
      final statusCodeMatch = statusCodeRegex.firstMatch(e.toString());
      final statusCode = statusCodeMatch != null 
          ? int.tryParse(statusCodeMatch.group(1) ?? '') 
          : null;
          
      // Extract error code if present
      final codeRegex = RegExp(r'code: ([^,)]+)');
      final codeMatch = codeRegex.firstMatch(e.toString());
      final code = codeMatch?.group(1);
      
      return AuthException(message, statusCode: statusCode, code: code);
    }
    
    // Default error message
    return AuthException(e.toString());
  }
  
  @override
  String toString() => message;
}

/// Interface for authentication data source
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<UserProfile> login({
    required String email,
    required String password,
  });

  /// Sign up a new user
  Future<UserProfile> signUp({
    required String displayName,
    required String email,
    required String password,
    bool receiveUpdates = false,
  });

  /// Reset password for the given email
  Future<void> resetPassword({required String email});

  /// Sign out the current user
  Future<void> signOut();

  /// Get current authenticated user
  Future<User?> getCurrentUser();
}

/// Implementation of authentication data source with Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserProfile> login({required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw const AuthException('User not found');
      }
      
      await _ensureUserProfileExists(response.user!);
      
      return await _getUserProfile(response.user!.id);
    } catch (e) {
      throw AuthException.fromSupabaseException(e);
    }
  }

  @override
  Future<UserProfile> signUp({
    required String displayName,
    required String email,
    required String password,
    bool receiveUpdates = false,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': displayName,
        },
      );
      
      if (response.user == null) {
        throw const AuthException('Failed to create user');
      }
      
      await _ensureUserProfileExists(response.user!, displayName: displayName);
      
      return await _getUserProfile(response.user!.id);
    } catch (e) {
      throw AuthException.fromSupabaseException(e);
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://reset-callback/',
      );
    } catch (e) {
      throw AuthException.fromSupabaseException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException.fromSupabaseException(e);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return supabaseClient.auth.currentUser;
    } catch (e) {
        return null;
      }
  }

  /// Ensures a user profile exists for the given user
  Future<void> _ensureUserProfileExists(User user, {String? displayName}) async {
    // Check if profile exists
    final existing = await supabaseClient
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    
    // Create profile if it doesn't exist
    if (existing == null) {
      String name = displayName ?? 'User';
      if (name.isEmpty && user.userMetadata != null && user.userMetadata!.containsKey('full_name')) {
        name = user.userMetadata!['full_name'] as String;
      } else if (name.isEmpty && user.email != null) {
        name = user.email!.split('@').first;
      }
      
      await supabaseClient
          .from('user_profiles')
          .insert({
            'id': user.id, // UUID primary key
            'user_id': user.id, // Foreign key to auth.users
            'display_name': name,
            'email': user.email ?? '',
            'dietary_prefs': [],
            'cooking_goals': [],
            'theme_preference': 'system',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
    }
  }
  
  /// Gets a user profile by ID
  Future<UserProfile> _getUserProfile(String userId) async {
    final profile = await supabaseClient
          .from('user_profiles')
          .select()
        .eq('user_id', userId)
          .single();
      
    return UserProfile.fromJson(profile);
  }
} 