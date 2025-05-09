import '../../domain/entities/recipe_detail.dart';

class RecipeDetailModel extends RecipeDetail {
  const RecipeDetailModel({
    required super.id,
    required super.title,
    required super.image,
    required super.summary,
    required super.readyInMinutes,
    required super.servings,
    required super.dishTypes,
    required super.diets,
    required super.vegetarian,
    required super.vegan,
    required super.glutenFree,
    required super.dairyFree,
    required super.veryHealthy,
    required super.cheap,
    required super.veryPopular,
    required super.sustainable,
    super.weightWatcherSmartPoints,
    super.sourceUrl,
    super.sourceName,
    super.healthScore,
    super.pricePerServing,
    required super.extendedIngredients,
    required super.analyzedInstructions,
    super.nutrition,
    super.isFavorite,
  });

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing recipe detail from JSON');
    try {
    // Process image URL to ensure it has proper schema
    String imageUrl = json['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://spoonacular.com/recipeImages/$imageUrl';
    }
    
    // Parse dish types or provide empty list
    List<String> dishTypes = [];
    if (json['dishTypes'] != null) {
        try {
      dishTypes = List<String>.from(json['dishTypes']);
        } catch (e) {
          print('⚠️ Error parsing dishTypes: $e');
        }
    }
    
    // Parse diets or provide empty list
    List<String> diets = [];
    if (json['diets'] != null) {
        try {
      diets = List<String>.from(json['diets']);
        } catch (e) {
          print('⚠️ Error parsing diets: $e');
        }
    }
    
      // Parse ingredients safely
    List<Ingredient> ingredients = [];
    if (json['extendedIngredients'] != null) {
        try {
          for (var ingredientJson in json['extendedIngredients']) {
            try {
              ingredients.add(IngredientModel.fromJson(ingredientJson));
            } catch (e) {
              print('⚠️ Error parsing individual ingredient: $e');
            }
          }
        } catch (e) {
          print('⚠️ Error parsing ingredients: $e');
        }
      }
    
    // Parse nutrition info if available
    NutritionInfo? nutritionInfo;
    if (json['nutrition'] != null) {
        try {
      nutritionInfo = NutritionInfoModel.fromJson(json['nutrition']);
        } catch (e) {
          print('⚠️ Error parsing nutrition info: $e');
        }
    }

      // Parse safely with null checks and default values for all fields
    return RecipeDetailModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? 'Untitled Recipe',
        image: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/640x360?text=No+Image',
        summary: json['summary'] ?? 'No summary available',
        readyInMinutes: json['readyInMinutes'] != null ? 
          (json['readyInMinutes'] is int ? json['readyInMinutes'] : int.tryParse(json['readyInMinutes'].toString()) ?? 0) : 0,
        servings: json['servings'] != null ? 
          (json['servings'] is int ? json['servings'] : int.tryParse(json['servings'].toString()) ?? 1) : 1,
      dishTypes: dishTypes,
      diets: diets,
      vegetarian: json['vegetarian'] ?? false,
      vegan: json['vegan'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      dairyFree: json['dairyFree'] ?? false,
      veryHealthy: json['veryHealthy'] ?? false,
      cheap: json['cheap'] ?? false,
      veryPopular: json['veryPopular'] ?? false,
      sustainable: json['sustainable'] ?? false,
        weightWatcherSmartPoints: json['weightWatcherSmartPoints'] is int ? 
          json['weightWatcherSmartPoints'] : int.tryParse(json['weightWatcherSmartPoints']?.toString() ?? '0'),
        sourceUrl: json['sourceUrl'] as String?,
        sourceName: json['sourceName'] as String?,
        healthScore: json['healthScore'] is int ? 
          json['healthScore'] : int.tryParse(json['healthScore']?.toString() ?? '0'),
        pricePerServing: json['pricePerServing'] != null ? 
          (json['pricePerServing'] is double ? json['pricePerServing'] : 
           double.tryParse(json['pricePerServing'].toString()) ?? 0.0) : 0.0,
      extendedIngredients: ingredients,
        analyzedInstructions: [], // Analyzed instructions are fetched separately
      nutrition: nutritionInfo,
    );
    } catch (e) {
      print('🔴 Critical error parsing recipe: $e');
      // Return a minimal valid recipe model to avoid crashing
      return RecipeDetailModel(
        id: json['id'] ?? 0,
        title: 'Error loading recipe',
        image: 'https://via.placeholder.com/640x360?text=Error+Loading+Recipe',
        summary: 'There was an error loading this recipe. Please try again later.',
        readyInMinutes: 0,
        servings: 1,
        dishTypes: [],
        diets: [],
        vegetarian: false,
        vegan: false,
        glutenFree: false,
        dairyFree: false,
        veryHealthy: false,
        cheap: false,
        veryPopular: false,
        sustainable: false,
        extendedIngredients: [],
        analyzedInstructions: [],
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'summary': summary,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'dishTypes': dishTypes,
      'diets': diets,
      'vegetarian': vegetarian,
      'vegan': vegan,
      'glutenFree': glutenFree,
      'dairyFree': dairyFree,
      'veryHealthy': veryHealthy,
      'cheap': cheap,
      'veryPopular': veryPopular,
      'sustainable': sustainable,
      'weightWatcherSmartPoints': weightWatcherSmartPoints,
      'sourceUrl': sourceUrl,
      'sourceName': sourceName,
      'healthScore': healthScore,
      'pricePerServing': pricePerServing,
      'extendedIngredients': extendedIngredients.map((x) {
        if (x is IngredientModel) {
          return x.toJson();
        }
        return {};
      }).toList(),
      'nutrition': nutrition is NutritionInfoModel ? (nutrition as NutritionInfoModel).toJson() : null,
    };
  }
}

class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.unit,
    super.originalName,
    super.image,
    super.consistency,
    super.aisle,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://spoonacular.com/cdn/ingredients_100x100/$imageUrl';
    }

    return IngredientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      originalName: json['originalName'] ?? json['original'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      image: imageUrl,
      consistency: json['consistency'] as String?,
      aisle: json['aisle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'originalName': originalName,
      'amount': amount,
      'unit': unit,
      'image': image,
      'consistency': consistency,
      'aisle': aisle,
    };
  }
}

class InstructionStepModel extends InstructionStep {
  const InstructionStepModel({
    required super.number,
    required super.step,
    required super.ingredients,
    required super.equipment,
  });

  factory InstructionStepModel.fromJson(Map<String, dynamic> json) {
    try {
    List<IngredientReference> ingredients = [];
    if (json['ingredients'] != null) {
        try {
      ingredients = List<IngredientReferenceModel>.from(
        json['ingredients'].map((x) => IngredientReferenceModel.fromJson(x))
      );
        } catch (e) {
          print('⚠️ Error parsing instruction ingredients: $e');
        }
    }

    List<EquipmentReference> equipment = [];
    if (json['equipment'] != null) {
        try {
      equipment = List<EquipmentReferenceModel>.from(
        json['equipment'].map((x) => EquipmentReferenceModel.fromJson(x))
      );
        } catch (e) {
          print('⚠️ Error parsing instruction equipment: $e');
        }
    }

    return InstructionStepModel(
        number: json['number'] != null ? 
          (json['number'] is int ? json['number'] : int.tryParse(json['number'].toString()) ?? 0) : 0,
      step: json['step'] ?? '',
      ingredients: ingredients,
      equipment: equipment,
    );
    } catch (e) {
      print('⚠️ Error parsing instruction step: $e');
      return const InstructionStepModel(
        number: 0,
        step: 'Error parsing step',
        ingredients: [],
        equipment: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'step': step,
      'ingredients': ingredients.map((x) {
        if (x is IngredientReferenceModel) {
          return x.toJson();
        }
        return {};
      }).toList(),
      'equipment': equipment.map((x) {
        if (x is EquipmentReferenceModel) {
          return x.toJson();
        }
        return {};
      }).toList(),
    };
  }
}

class IngredientReferenceModel extends IngredientReference {
  const IngredientReferenceModel({
    required super.id,
    required super.name,
    super.image,
  });

  factory IngredientReferenceModel.fromJson(Map<String, dynamic> json) {
    try {
    String imageUrl = json['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://spoonacular.com/cdn/ingredients_100x100/$imageUrl';
    }

    return IngredientReferenceModel(
        id: json['id'] != null ? 
          (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0) : 0,
      name: json['name'] ?? '',
      image: imageUrl,
    );
    } catch (e) {
      print('⚠️ Error parsing ingredient reference: $e');
      return const IngredientReferenceModel(
        id: 0,
        name: 'Unknown ingredient',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class EquipmentReferenceModel extends EquipmentReference {
  const EquipmentReferenceModel({
    required super.id,
    required super.name,
    super.image,
  });

  factory EquipmentReferenceModel.fromJson(Map<String, dynamic> json) {
    try {
    String imageUrl = json['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://spoonacular.com/cdn/equipment_100x100/$imageUrl';
    }

    return EquipmentReferenceModel(
        id: json['id'] != null ? 
          (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0) : 0,
      name: json['name'] ?? '',
      image: imageUrl,
    );
    } catch (e) {
      print('⚠️ Error parsing equipment reference: $e');
      return const EquipmentReferenceModel(
        id: 0,
        name: 'Unknown equipment',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class NutritionInfoModel extends NutritionInfo {
  const NutritionInfoModel({
    required super.nutrients,
    required super.properties,
    required super.flavonoids,
  });

  factory NutritionInfoModel.fromJson(Map<String, dynamic> json) {
    try {
    List<Nutrient> nutrients = [];
    if (json['nutrients'] != null) {
        try {
          for (var nutrientJson in json['nutrients']) {
            try {
              nutrients.add(NutrientModel.fromJson(nutrientJson));
            } catch (e) {
              print('⚠️ Error parsing individual nutrient: $e');
            }
          }
        } catch (e) {
          print('⚠️ Error parsing nutrients list: $e');
        }
    }

    List<Nutrient> properties = [];
    if (json['properties'] != null) {
        try {
          for (var propertyJson in json['properties']) {
            try {
              properties.add(NutrientModel.fromJson(propertyJson));
            } catch (e) {
              print('⚠️ Error parsing individual property: $e');
            }
          }
        } catch (e) {
          print('⚠️ Error parsing properties list: $e');
        }
    }

    List<Nutrient> flavonoids = [];
    if (json['flavonoids'] != null) {
        try {
          for (var flavonoidJson in json['flavonoids']) {
            try {
              flavonoids.add(NutrientModel.fromJson(flavonoidJson));
            } catch (e) {
              print('⚠️ Error parsing individual flavonoid: $e');
            }
          }
        } catch (e) {
          print('⚠️ Error parsing flavonoids list: $e');
        }
    }

    return NutritionInfoModel(
      nutrients: nutrients,
      properties: properties,
      flavonoids: flavonoids,
    );
    } catch (e) {
      print('⚠️ Error parsing nutrition info: $e');
      return const NutritionInfoModel(
        nutrients: [],
        properties: [],
        flavonoids: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nutrients': nutrients.map((x) {
        if (x is NutrientModel) {
          return x.toJson();
        }
        return {};
      }).toList(),
      'properties': properties.map((x) {
        if (x is NutrientModel) {
          return x.toJson();
        }
        return {};
      }).toList(),
      'flavonoids': flavonoids.map((x) {
        if (x is NutrientModel) {
          return x.toJson();
        }
        return {};
      }).toList(),
    };
  }
}

class NutrientModel extends Nutrient {
  const NutrientModel({
    required super.name,
    required super.amount,
    required super.unit,
    super.percentOfDailyNeeds,
  });

  factory NutrientModel.fromJson(Map<String, dynamic> json) {
    try {
      double amount = 0;
      if (json['amount'] != null) {
        amount = json['amount'] is double ? json['amount'] : 
                 json['amount'] is int ? json['amount'].toDouble() : 
                 double.tryParse(json['amount'].toString()) ?? 0;
      }
      
      double? percentOfDailyNeeds;
      if (json['percentOfDailyNeeds'] != null) {
        percentOfDailyNeeds = json['percentOfDailyNeeds'] is double ? json['percentOfDailyNeeds'] : 
                              json['percentOfDailyNeeds'] is int ? json['percentOfDailyNeeds'].toDouble() : 
                              double.tryParse(json['percentOfDailyNeeds'].toString());
      }
      
    return NutrientModel(
      name: json['name'] ?? '',
        amount: amount,
      unit: json['unit'] ?? '',
        percentOfDailyNeeds: percentOfDailyNeeds,
      );
    } catch (e) {
      print('⚠️ Error parsing nutrient: $e');
      return const NutrientModel(
        name: 'Unknown',
        amount: 0,
        unit: '',
    );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'percentOfDailyNeeds': percentOfDailyNeeds,
    };
  }
} 