import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Fetches trending recipes
  Future<Either<Failure, List<Recipe>>> getTrendingRecipes();
  
  /// Fetches available recipe categories
  Future<Either<Failure, List<String>>> getCategories();
  
  /// Fetches recipes for a specific category
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(
    String category, {
    int offset = 0,
    int limit = 20,
  });
  
  /// Checks if recipes are favorited by the current user
  Future<Either<Failure, List<bool>>> checkFavoriteStatus(List<int> recipeIds);
} 