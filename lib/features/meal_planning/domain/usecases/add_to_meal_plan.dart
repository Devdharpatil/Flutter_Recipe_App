import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

/// Use case for adding a recipe to the meal plan
class AddToMealPlan implements UseCase<MealPlan, AddToMealPlanParams> {
  final MealPlanRepository repository;

  AddToMealPlan(this.repository);

  @override
  Future<Either<Failure, MealPlan>> call(AddToMealPlanParams params) {
    return repository.addToMealPlan(
      recipeId: params.recipeId,
      recipeTitle: params.recipeTitle,
      recipeImage: params.recipeImage,
      date: params.date,
      mealType: params.mealType,
      servings: params.servings,
    );
  }
}

/// Parameters for the [AddToMealPlan] use case
class AddToMealPlanParams extends Equatable {
  final int recipeId;
  final String recipeTitle;
  final String recipeImage;
  final DateTime date;
  final MealType mealType;
  final int servings;

  const AddToMealPlanParams({
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImage,
    required this.date,
    required this.mealType,
    this.servings = 1,
  });

  @override
  List<Object> get props => [
    recipeId,
    recipeTitle,
    recipeImage,
    date,
    mealType,
    servings,
  ];
} 