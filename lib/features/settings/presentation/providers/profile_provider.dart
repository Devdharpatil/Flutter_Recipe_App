import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_simple.dart';

/// A simple provider that fetches basic user profile information.
/// 
/// This is a temporary solution until we implement the full ProfileBloc.
class ProfileProvider extends ChangeNotifier {
  UserProfileSimple _userProfile = UserProfileSimple.empty;
  bool _isLoading = false;
  String? _error;
  
  /// The current user profile data
  UserProfileSimple get userProfile => _userProfile;
  
  /// Whether the profile is currently loading
  bool get isLoading => _isLoading;
  
  /// Any error that occurred during loading
  String? get error => _error;
  
  /// Constructor that immediately loads profile data
  ProfileProvider() {
    loadProfileData();
  }
  
  /// Load basic profile data from Supabase
  Future<void> loadProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        // Get user profile data from Supabase
        final response = await supabase
            .from('user_profiles')
            .select('display_name, email, avatar_url')
            .eq('user_id', user.id)
            .single();
        
        // Create user profile from response
        if (response != null) {
          _userProfile = UserProfileSimple(
            displayName: response['display_name'] ?? '',
            email: response['email'] ?? user.email ?? '',
            avatarUrl: response['avatar_url'],
          );
        } else {
          // If no profile exists yet, create one with default values
          _userProfile = UserProfileSimple(
            displayName: user.userMetadata?['full_name'] ?? '',
            email: user.email ?? '',
            avatarUrl: null,
          );
        }
        
        _error = null;
      } else {
        _error = 'No authenticated user found';
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
      // Fallback to using available auth data
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _userProfile = UserProfileSimple(
          displayName: user.userMetadata?['full_name'] ?? 'User',
          email: user.email ?? '',
          avatarUrl: null,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 