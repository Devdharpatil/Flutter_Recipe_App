import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe_detail.dart';
import '../entities/ingredient_substitutes.dart';

abstract class RecipeDetailRepository {
  /// Fetches detailed information for a specific recipe by its ID
  /// Returns [RecipeDetail] on success, [Failure] on error
  Future<Either<Failure, RecipeDetail>> getRecipeDetail(int recipeId);
  
  /// Toggles favorite status for a recipe
  /// Returns [bool] representing the new favorite status, [Failure] on error
  Future<Either<Failure, bool>> toggleFavorite(int recipeId, bool currentStatus);
  
  /// Gets the favorite status for a specific recipe
  /// Returns [bool] representing if recipe is favorite, [Failure] on error
  Future<Either<Failure, bool>> isFavorite(int recipeId);
  
  /// Gets substitutes for an ingredient
  /// Returns [IngredientSubstitutes] on success, [Failure] on error
  Future<Either<Failure, IngredientSubstitutes>> getIngredientSubstitutes(String ingredientName);
} 