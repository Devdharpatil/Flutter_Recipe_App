import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meal_plan.dart';

/// Repository interface for meal planning operations
abstract class MealPlanRepository {
  /// Get all meal plans for the current user
  Future<Either<Failure, List<MealPlan>>> getMealPlans();
  
  /// Get meal plans for a specific date range
  Future<Either<Failure, List<MealPlan>>> getMealPlansForDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Add a recipe to the meal plan
  Future<Either<Failure, MealPlan>> addToMealPlan({
    required int recipeId,
    required String recipeTitle,
    required String recipeImage,
    required DateTime date,
    required MealType mealType,
    int servings = 1,
  });
  
  /// Update an existing meal plan
  Future<Either<Failure, MealPlan>> updateMealPlan(MealPlan mealPlan);
  
  /// Delete a meal plan by ID
  Future<Either<Failure, bool>> deleteMealPlan(String mealPlanId);
  
  /// Get meal plans for a specific date
  Future<Either<Failure, List<MealPlan>>> getMealPlansForDate(DateTime date);
  
  /// Get meal plans for a specific recipe
  Future<Either<Failure, List<MealPlan>>> getMealPlansForRecipe(int recipeId);
} 