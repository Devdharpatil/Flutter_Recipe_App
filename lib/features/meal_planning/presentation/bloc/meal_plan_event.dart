import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_plan.dart';
import 'meal_plan_state.dart';

abstract class MealPlanEvent extends Equatable {
  const MealPlanEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load meal plans for the current selected date range
class LoadMealPlans extends MealPlanEvent {
  const LoadMealPlans();
}

/// Event to change the selected date
class ChangeSelectedDate extends MealPlanEvent {
  final DateTime date;

  const ChangeSelectedDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Event to change view mode (daily, weekly, monthly)
class ChangeViewMode extends MealPlanEvent {
  final ViewMode viewMode;

  const ChangeViewMode(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

/// Event to add a recipe to the meal plan
class AddToMealPlan extends MealPlanEvent {
  final int recipeId;
  final String recipeTitle;
  final String recipeImage;
  final DateTime date;
  final MealType mealType;
  final int servings;

  const AddToMealPlan({
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImage,
    required this.date,
    required this.mealType,
    this.servings = 1,
  });

  @override
  List<Object?> get props => [
    recipeId,
    recipeTitle,
    recipeImage,
    date,
    mealType,
    servings,
  ];
}

/// Event to update an existing meal plan
class UpdateMealPlan extends MealPlanEvent {
  final MealPlan mealPlan;

  const UpdateMealPlan(this.mealPlan);

  @override
  List<Object?> get props => [mealPlan];
}

/// Event to delete a meal plan
class DeleteMealPlan extends MealPlanEvent {
  final MealPlan mealPlan;

  const DeleteMealPlan(this.mealPlan);

  @override
  List<Object?> get props => [mealPlan];
}

/// Event to navigate to a specific date
class NavigateToDate extends MealPlanEvent {
  final DateTime date;

  const NavigateToDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Event to toggle favorite status of a recipe
class ToggleFavoriteMealPlan extends MealPlanEvent {
  final int recipeId;
  final bool isFavorite;

  const ToggleFavoriteMealPlan({
    required this.recipeId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [recipeId, isFavorite];
} 