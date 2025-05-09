/// A simple model representing basic user profile information for the settings screen.
class UserProfileSimple {
  final String displayName;
  final String email;
  final String? avatarUrl;
  
  const UserProfileSimple({
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });
  
  static const empty = UserProfileSimple(
    displayName: '',
    email: '',
    avatarUrl: null,
  );
  
  /// Create a copy of this profile with optional new values
  UserProfileSimple copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
  }) {
    return UserProfileSimple(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
} 