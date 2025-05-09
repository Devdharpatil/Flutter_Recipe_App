import '../../domain/entities/user_preferences.dart';

/// Model implementation of the UserPreferences entity
class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.dietaryPrefs,
    required super.cookingGoals,
  });

  /// Factory constructor to create a UserPreferencesModel from a JSON map
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      dietaryPrefs: _parseStringList(json['dietary_prefs']),
      cookingGoals: _parseStringList(json['cooking_goals']),
    );
  }

  /// Convert model to a JSON map
  Map<String, dynamic> toJson() => {
        'dietary_prefs': dietaryPrefs,
        'cooking_goals': cookingGoals,
      };
      
  /// Helper to parse string lists from Supabase PostgreSQL arrays
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    
    return [];
  }
} 