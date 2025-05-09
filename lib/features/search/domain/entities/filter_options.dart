import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FilterOptions extends Equatable {
  final String? diet;
  final List<String> diets;
  final List<String> intolerances;
  final List<String> cuisines;
  final int? maxReadyTime;
  final List<String> includeIngredients;
  final List<String> excludeIngredients;
  final RangeValues? calorieRange;
  final RangeValues? proteinRange;
  final RangeValues? carbsRange;
  final RangeValues? fatRange;
  final List<String> mealTypes;

  const FilterOptions({
    this.diet,
    this.diets = const [],
    this.intolerances = const [],
    this.cuisines = const [],
    this.maxReadyTime,
    this.includeIngredients = const [],
    this.excludeIngredients = const [],
    this.calorieRange,
    this.proteinRange,
    this.carbsRange,
    this.fatRange,
    this.mealTypes = const [],
  });

  @override
  List<Object?> get props => [
    diet,
    diets,
    intolerances,
    cuisines,
    maxReadyTime,
    includeIngredients,
    excludeIngredients,
    calorieRange,
    proteinRange,
    carbsRange,
    fatRange,
    mealTypes,
  ];

  FilterOptions copyWith({
    String? diet,
    bool? clearDiet,
    List<String>? diets,
    List<String>? intolerances,
    List<String>? cuisines,
    int? maxReadyTime,
    List<String>? includeIngredients,
    List<String>? excludeIngredients,
    RangeValues? calorieRange,
    RangeValues? proteinRange,
    RangeValues? carbsRange,
    RangeValues? fatRange,
    List<String>? mealTypes,
    bool? clearMaxReadyTime,
    bool? clearCalorieRange,
    bool? clearProteinRange,
    bool? clearCarbsRange,
    bool? clearFatRange,
  }) {
    return FilterOptions(
      diet: clearDiet == true ? null : (diet ?? this.diet),
      diets: diets ?? this.diets,
      intolerances: intolerances ?? this.intolerances,
      cuisines: cuisines ?? this.cuisines,
      maxReadyTime: clearMaxReadyTime == true ? null : (maxReadyTime ?? this.maxReadyTime),
      includeIngredients: includeIngredients ?? this.includeIngredients,
      excludeIngredients: excludeIngredients ?? this.excludeIngredients,
      calorieRange: clearCalorieRange == true ? null : (calorieRange ?? this.calorieRange),
      proteinRange: clearProteinRange == true ? null : (proteinRange ?? this.proteinRange),
      carbsRange: clearCarbsRange == true ? null : (carbsRange ?? this.carbsRange),
      fatRange: clearFatRange == true ? null : (fatRange ?? this.fatRange),
      mealTypes: mealTypes ?? this.mealTypes,
    );
  }

  bool get isEmpty => 
      diet == null &&
      diets.isEmpty &&
      intolerances.isEmpty &&
      cuisines.isEmpty &&
      maxReadyTime == null &&
      includeIngredients.isEmpty &&
      excludeIngredients.isEmpty &&
      calorieRange == null &&
      proteinRange == null &&
      carbsRange == null &&
      fatRange == null &&
      mealTypes.isEmpty;

  static const FilterOptions empty = FilterOptions();

  // Pre-defined diet options 
  static const List<String> dietOptions = [
    'Gluten Free',
    'Ketogenic',
    'Vegetarian',
    'Lacto-Vegetarian',
    'Ovo-Vegetarian',
    'Vegan',
    'Pescetarian',
    'Paleo',
    'Primal',
    'Low FODMAP',
    'Whole30',
  ];

  // Pre-defined meal type options
  static const List<String> mealTypeOptions = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Appetizer',
    'Main Course',
    'Side Dish',
    'Soup',
    'Salad',
    'Beverage',
  ];

  // Pre-defined intolerances options
  static const List<String> intoleranceOptions = [
    'Dairy',
    'Egg',
    'Gluten',
    'Grain',
    'Peanut',
    'Seafood',
    'Sesame',
    'Shellfish',
    'Soy',
    'Sulfite',
    'Tree Nut',
    'Wheat',
  ];

  // Pre-defined cuisine options
  static const List<String> cuisineOptions = [
    'African',
    'American',
    'British',
    'Cajun',
    'Caribbean',
    'Chinese',
    'Eastern European',
    'European',
    'French',
    'German',
    'Greek',
    'Indian',
    'Irish',
    'Italian',
    'Japanese',
    'Jewish',
    'Korean',
    'Latin American',
    'Mediterranean',
    'Mexican',
    'Middle Eastern',
    'Nordic',
    'Southern',
    'Spanish',
    'Thai',
    'Vietnamese',
  ];

  // Convert to query parameters for API calls
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (diet != null) {
      params['diet'] = diet;
    } else if (diets.isNotEmpty) {
      params['diets'] = diets.join(',');
    }
    
    if (intolerances.isNotEmpty) {
      params['intolerances'] = intolerances.join(',');
    }
    
    if (cuisines.isNotEmpty) {
      params['cuisine'] = cuisines.join(',');
    }
    
    if (maxReadyTime != null) {
      params['maxReadyTime'] = maxReadyTime.toString();
    }
    
    if (mealTypes.isNotEmpty) {
      params['type'] = mealTypes.join(',');
    }
    
    if (includeIngredients.isNotEmpty) {
      params['includeIngredients'] = includeIngredients.join(',');
    }
    
    if (excludeIngredients.isNotEmpty) {
      params['excludeIngredients'] = excludeIngredients.join(',');
    }
    
    if (calorieRange != null) {
      params['minCalories'] = calorieRange!.start.toInt().toString();
      params['maxCalories'] = calorieRange!.end.toInt().toString();
    }
    
    if (proteinRange != null) {
      params['minProtein'] = proteinRange!.start.toInt().toString();
      params['maxProtein'] = proteinRange!.end.toInt().toString();
    }
    
    if (carbsRange != null) {
      params['minCarbs'] = carbsRange!.start.toInt().toString();
      params['maxCarbs'] = carbsRange!.end.toInt().toString();
    }
    
    if (fatRange != null) {
      params['minFat'] = fatRange!.start.toInt().toString();
      params['maxFat'] = fatRange!.end.toInt().toString();
    }
    
    return params;
  }

  // Helper methods to toggle diet and meal type selections
  FilterOptions toggleDiet(String diet) {
    final updatedDiets = List<String>.from(diets);
    if (updatedDiets.contains(diet)) {
      updatedDiets.remove(diet);
    } else {
      updatedDiets.add(diet);
    }
    return copyWith(diets: updatedDiets);
  }
  
  FilterOptions toggleMealType(String mealType) {
    final updatedMealTypes = List<String>.from(mealTypes);
    if (updatedMealTypes.contains(mealType)) {
      updatedMealTypes.remove(mealType);
    } else {
      updatedMealTypes.add(mealType);
    }
    return copyWith(mealTypes: updatedMealTypes);
  }
}

class RangeValues {
  final double start;
  final double end;

  const RangeValues(this.start, this.end);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RangeValues && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
} 