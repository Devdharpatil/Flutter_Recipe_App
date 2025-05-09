import '../../domain/entities/ingredient_substitutes.dart';

class IngredientSubstitutesModel extends IngredientSubstitutes {
  const IngredientSubstitutesModel({
    required super.ingredient,
    required super.substitutes,
    required super.message,
  });

  factory IngredientSubstitutesModel.fromJson(Map<String, dynamic> json) {
    return IngredientSubstitutesModel(
      ingredient: json['ingredient'] ?? '',
      substitutes: json['substitutes'] != null 
          ? List<String>.from(json['substitutes']) 
          : [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'substitutes': substitutes,
      'message': message,
    };
  }
} 