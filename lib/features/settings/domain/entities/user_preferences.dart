import 'package:equatable/equatable.dart';

/// Entity representing user preferences
class UserPreferences extends Equatable {
  final List<String> dietaryPrefs;
  final List<String> cookingGoals;

  const UserPreferences({
    required this.dietaryPrefs,
    required this.cookingGoals,
  });

  @override
  List<Object?> get props => [dietaryPrefs, cookingGoals];
} 