import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final int id;
  final String title;
  final String image;
  final int? readyInMinutes;
  final int? servings;
  final List<String>? dishTypes;
  final List<String>? diets;
  final bool isFavorite;
  double? healthScore;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    this.readyInMinutes,
    this.servings,
    this.dishTypes,
    this.diets,
    this.isFavorite = false,
    this.healthScore,
  });

  @override
  int get hashCode => id.hashCode;
  
  @override
  bool operator ==(Object other) => 
    identical(this, other) || 
    other is Recipe && other.id == id;

  @override
  List<Object?> get props => [
        id,
        title,
        image,
        readyInMinutes,
        servings,
        dishTypes,
        diets,
        isFavorite,
        healthScore,
      ];

  Recipe copyWith({
    int? id,
    String? title,
    String? image,
    int? readyInMinutes,
    int? servings,
    List<String>? dishTypes,
    List<String>? diets,
    bool? isFavorite,
    double? healthScore,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      servings: servings ?? this.servings,
      dishTypes: dishTypes ?? this.dishTypes,
      diets: diets ?? this.diets,
      isFavorite: isFavorite ?? this.isFavorite,
      healthScore: healthScore ?? this.healthScore,
    );
  }
} 