import 'package:equatable/equatable.dart';

/// Entity representing a user's profile
class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool receiveUpdates;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.receiveUpdates = false,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        email,
        createdAt,
        updatedAt,
        receiveUpdates,
        avatarUrl,
      ];

  /// Factory constructor to create a UserProfile from a JSON map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      displayName: json['display_name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      receiveUpdates: json['receive_updates'] ?? false,
      avatarUrl: json['avatar_url'],
    );
  }

  /// Convert entity to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'display_name': displayName,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'receive_updates': receiveUpdates,
        'avatar_url': avatarUrl,
      };

  UserProfile copyWith({
    String? displayName,
    bool? receiveUpdates,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      receiveUpdates: receiveUpdates ?? this.receiveUpdates,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
} 