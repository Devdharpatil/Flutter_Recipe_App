import 'package:equatable/equatable.dart';

/// Represents a meal type (breakfast, lunch, dinner, etc.)
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;
  
  String get displayName {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
    }
  }
  
  String get emoji {
    switch (this) {
      case MealType.breakfast: return '🥣';
      case MealType.lunch: return '🥗';
      case MealType.dinner: return '🍲';
      case MealType.snack: return '🍎';
    }
  }
}

/// Represents a planned meal entry in the meal planner
class MealPlan extends Equatable {
  final String id;
  final int recipeId;
  final String recipeTitle;
  final String recipeImage;
  final DateTime date;
  final MealType mealType;
  final int servings;
  final DateTime createdAt;
  final bool isFavorite;
  final DateTime? originalDate; // Tracks the original date before rescheduling
  
  const MealPlan({
    required this.id,
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImage,
    required this.date,
    required this.mealType,
    this.servings = 1,
    required this.createdAt,
    this.isFavorite = false,
    this.originalDate,
  });
  
  @override
  List<Object?> get props => [
    id, 
    recipeId, 
    recipeTitle, 
    recipeImage, 
    date, 
    mealType, 
    servings, 
    createdAt,
    isFavorite,
    originalDate
  ];
  
  /// Creates a copy of this MealPlan with the given fields replaced with the new values.
  MealPlan copyWith({
    String? id,
    int? recipeId,
    String? recipeTitle,
    String? recipeImage,
    DateTime? date,
    MealType? mealType,
    int? servings,
    DateTime? createdAt,
    bool? isFavorite,
    DateTime? originalDate,
  }) {
    return MealPlan(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeImage: recipeImage ?? this.recipeImage,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      originalDate: originalDate ?? this.originalDate,
    );
  }
  
  /// Creates a [MealPlan] with a new date
  MealPlan reschedule(DateTime newDate) {
    return copyWith(
      date: newDate,
      originalDate: originalDate ?? date, // Track the original date
      createdAt: DateTime.now(),
    );
  }
  
  /// Creates a [MealPlan] with a new meal type
  MealPlan changeMealType(MealType newMealType) {
    return copyWith(
      mealType: newMealType,
      createdAt: DateTime.now(),
    );
  }
} 