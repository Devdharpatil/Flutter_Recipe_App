import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    required super.id,
    required super.title,
    required super.image,
    super.readyInMinutes,
    super.servings,
    super.dishTypes,
    super.diets,
    super.isFavorite,
    super.healthScore,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert numeric values to int
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    // Helper function to safely convert numeric values to double
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }
    
    return RecipeModel(
      id: json['id'] is int ? json['id'] : toInt(json['id']) ?? 0,
      title: json['title'] ?? 'Untitled Recipe',
      // Handle different image URL formats from Spoonacular
      image: json['image']?.contains('https://') == true
          ? json['image']
          : 'https://spoonacular.com/recipeImages/${json['image'] ?? 'placeholder.jpg'}',
      readyInMinutes: toInt(json['readyInMinutes']),
      servings: toInt(json['servings']),
      dishTypes: json['dishTypes'] != null
          ? List<String>.from(json['dishTypes'])
          : null,
      diets: json['diets'] != null ? List<String>.from(json['diets']) : null,
      healthScore: toDouble(json['healthScore']),
      isFavorite: false, // Default value, will be updated from favorites data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'dishTypes': dishTypes,
      'diets': diets,
      'healthScore': healthScore,
    };
  }

  RecipeModel copyWithFavorite(bool isFavorite) {
    return RecipeModel(
      id: id,
      title: title,
      image: image,
      readyInMinutes: readyInMinutes,
      servings: servings,
      dishTypes: dishTypes,
      diets: diets,
      healthScore: healthScore,
      isFavorite: isFavorite,
    );
  }
} 