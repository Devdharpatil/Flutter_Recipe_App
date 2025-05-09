import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/filter_options.dart';

class FilterCubit extends Cubit<FilterOptions> {
  FilterCubit() : super(FilterOptions.empty);

  void updateDiet(String? diet) {
    emit(state.copyWith(diet: diet, clearDiet: diet == null));
  }

  void toggleIntolerance(String intolerance) {
    final intolerances = List<String>.from(state.intolerances);
    if (intolerances.contains(intolerance)) {
      intolerances.remove(intolerance);
    } else {
      intolerances.add(intolerance);
    }
    emit(state.copyWith(intolerances: intolerances));
  }

  void toggleCuisine(String cuisine) {
    final cuisines = List<String>.from(state.cuisines);
    if (cuisines.contains(cuisine)) {
      cuisines.remove(cuisine);
    } else {
      cuisines.add(cuisine);
    }
    emit(state.copyWith(cuisines: cuisines));
  }

  void updateMaxReadyTime(int? maxReadyTime) {
    emit(state.copyWith(
      maxReadyTime: maxReadyTime,
      clearMaxReadyTime: maxReadyTime == null,
    ));
  }

  void updateCalorieRange(RangeValues? calorieRange) {
    emit(state.copyWith(
      calorieRange: calorieRange,
      clearCalorieRange: calorieRange == null,
    ));
  }

  void updateProteinRange(RangeValues? proteinRange) {
    emit(state.copyWith(
      proteinRange: proteinRange,
      clearProteinRange: proteinRange == null,
    ));
  }

  void updateCarbsRange(RangeValues? carbsRange) {
    emit(state.copyWith(
      carbsRange: carbsRange,
      clearCarbsRange: carbsRange == null,
    ));
  }

  void updateFatRange(RangeValues? fatRange) {
    emit(state.copyWith(
      fatRange: fatRange,
      clearFatRange: fatRange == null,
    ));
  }

  void updateIncludeIngredients(List<String> ingredients) {
    emit(state.copyWith(includeIngredients: ingredients));
  }

  void updateExcludeIngredients(List<String> ingredients) {
    emit(state.copyWith(excludeIngredients: ingredients));
  }

  void reset() {
    emit(FilterOptions.empty);
  }
} 