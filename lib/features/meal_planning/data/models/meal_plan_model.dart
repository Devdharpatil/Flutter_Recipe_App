import '../../domain/entities/meal_plan.dart';

/// Data model implementation of MealPlan entity
class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.id,
    required super.recipeId,
    required super.recipeTitle,
    required super.recipeImage,
    required super.date,
    required super.mealType,
    super.servings = 1,
    required super.createdAt,
    super.isFavorite = false,
    super.originalDate,
  });
  
  /// Create a MealPlanModel from a JSON map
  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'],
      recipeId: json['recipe_id'],
      recipeTitle: json['recipe_title'],
      recipeImage: json['recipe_image'],
      date: DateTime.parse(json['date']),
      mealType: MealType.values.byName(json['meal_type']),
      servings: json['servings'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      isFavorite: json['is_favorite'] ?? false,
      originalDate: json['original_date'] != null ? DateTime.parse(json['original_date']) : null,
    );
  }
  
  /// Convert this MealPlanModel to a JSON map
  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'recipe_id': recipeId,
      'recipe_title': recipeTitle,
      'recipe_image': recipeImage,
      'date': date.toIso8601String(),
      'meal_type': mealType.name,
      'servings': servings,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
    };
    
    if (originalDate != null) {
      map['original_date'] = originalDate!.toIso8601String();
    }
    
    return map;
  }
  
  /// Creates a new MealPlanModel with a new ID
  factory MealPlanModel.create({
    required int recipeId,
    required String recipeTitle,
    required String recipeImage,
    required DateTime date,
    required MealType mealType,
    int servings = 1,
  }) {
    final now = DateTime.now();
    final id = '${recipeId}_${date.millisecondsSinceEpoch}_${mealType.name}_${now.millisecondsSinceEpoch}';
    
    return MealPlanModel(
      id: id,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      recipeImage: recipeImage,
      date: date,
      mealType: mealType,
      servings: servings,
      createdAt: now,
    );
  }
  
  /// Create a copy of this MealPlanModel with new values
  MealPlanModel copyWithModel({
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
    return MealPlanModel(
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
} 