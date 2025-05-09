import 'package:equatable/equatable.dart';

class RecipeDetail extends Equatable {
  final int id;
  final String title;
  final String image;
  final String summary;
  final int readyInMinutes;
  final int servings;
  final List<String> dishTypes;
  final List<String> diets;
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool dairyFree;
  final bool veryHealthy;
  final bool cheap;
  final bool veryPopular;
  final bool sustainable;
  final int? weightWatcherSmartPoints;
  final String? sourceUrl;
  final String? sourceName;
  final int? healthScore;
  final double? pricePerServing;
  final List<Ingredient> extendedIngredients;
  final List<InstructionStep> analyzedInstructions;
  final NutritionInfo? nutrition;
  final bool isFavorite;

  const RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.summary,
    required this.readyInMinutes,
    required this.servings,
    required this.dishTypes,
    required this.diets,
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
    required this.veryHealthy,
    required this.cheap,
    required this.veryPopular,
    required this.sustainable,
    this.weightWatcherSmartPoints,
    this.sourceUrl,
    this.sourceName,
    this.healthScore,
    this.pricePerServing,
    required this.extendedIngredients,
    required this.analyzedInstructions,
    this.nutrition,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        image,
        summary,
        readyInMinutes,
        servings,
        dishTypes,
        diets,
        vegetarian,
        vegan,
        glutenFree,
        dairyFree,
        veryHealthy,
        cheap,
        veryPopular,
        sustainable,
        weightWatcherSmartPoints,
        sourceUrl,
        sourceName,
        healthScore,
        pricePerServing,
        extendedIngredients,
        analyzedInstructions,
        nutrition,
        isFavorite,
      ];

  RecipeDetail copyWith({
    int? id,
    String? title,
    String? image,
    String? summary,
    int? readyInMinutes,
    int? servings,
    List<String>? dishTypes,
    List<String>? diets,
    bool? vegetarian,
    bool? vegan,
    bool? glutenFree,
    bool? dairyFree,
    bool? veryHealthy,
    bool? cheap,
    bool? veryPopular,
    bool? sustainable,
    int? weightWatcherSmartPoints,
    String? sourceUrl,
    String? sourceName,
    int? healthScore,
    double? pricePerServing,
    List<Ingredient>? extendedIngredients,
    List<InstructionStep>? analyzedInstructions,
    NutritionInfo? nutrition,
    bool? isFavorite,
  }) {
    return RecipeDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      summary: summary ?? this.summary,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      servings: servings ?? this.servings,
      dishTypes: dishTypes ?? this.dishTypes,
      diets: diets ?? this.diets,
      vegetarian: vegetarian ?? this.vegetarian,
      vegan: vegan ?? this.vegan,
      glutenFree: glutenFree ?? this.glutenFree,
      dairyFree: dairyFree ?? this.dairyFree,
      veryHealthy: veryHealthy ?? this.veryHealthy,
      cheap: cheap ?? this.cheap,
      veryPopular: veryPopular ?? this.veryPopular,
      sustainable: sustainable ?? this.sustainable,
      weightWatcherSmartPoints: weightWatcherSmartPoints ?? this.weightWatcherSmartPoints,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      healthScore: healthScore ?? this.healthScore,
      pricePerServing: pricePerServing ?? this.pricePerServing,
      extendedIngredients: extendedIngredients ?? this.extendedIngredients,
      analyzedInstructions: analyzedInstructions ?? this.analyzedInstructions,
      nutrition: nutrition ?? this.nutrition,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Ingredient extends Equatable {
  final int id;
  final String name;
  final String? originalName;
  final double amount;
  final String unit;
  final String? image;
  final String? consistency;
  final String? aisle;
  
  const Ingredient({
    required this.id,
    required this.name,
    this.originalName,
    required this.amount,
    required this.unit,
    this.image,
    this.consistency,
    this.aisle,
  });
  
  @override
  List<Object?> get props => [id, name, originalName, amount, unit, image, consistency, aisle];
}

class InstructionStep extends Equatable {
  final int number;
  final String step;
  final List<IngredientReference> ingredients;
  final List<EquipmentReference> equipment;
  
  const InstructionStep({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
  });
  
  @override
  List<Object> get props => [number, step, ingredients, equipment];
}

class IngredientReference extends Equatable {
  final int id;
  final String name;
  final String? image;
  
  const IngredientReference({
    required this.id,
    required this.name,
    this.image,
  });
  
  @override
  List<Object?> get props => [id, name, image];
}

class EquipmentReference extends Equatable {
  final int id;
  final String name;
  final String? image;
  
  const EquipmentReference({
    required this.id,
    required this.name,
    this.image,
  });
  
  @override
  List<Object?> get props => [id, name, image];
}

class NutritionInfo extends Equatable {
  final List<Nutrient> nutrients;
  final List<Nutrient> properties;
  final List<Nutrient> flavonoids;
  
  const NutritionInfo({
    required this.nutrients,
    required this.properties,
    required this.flavonoids,
  });
  
  @override
  List<Object> get props => [nutrients, properties, flavonoids];
}

class Nutrient extends Equatable {
  final String name;
  final double amount;
  final String unit;
  final double? percentOfDailyNeeds;
  
  const Nutrient({
    required this.name,
    required this.amount,
    required this.unit,
    this.percentOfDailyNeeds,
  });
  
  @override
  List<Object?> get props => [name, amount, unit, percentOfDailyNeeds];
} 