import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../datasources/favorites_datasource.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;
  final FavoritesDataSource favoritesDataSource;
  final NetworkInfo networkInfo;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.favoritesDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Recipe>>> getTrendingRecipes() async {
    if (await networkInfo.isConnected) {
      try {
        final recipes = await remoteDataSource.getTrendingRecipes();
        
        // Handle empty recipes list (this is a valid response, not an error)
        if (recipes.isEmpty) {
          return const Right([]);
        }
        
        // Get the recipe IDs to check favorite status
        final recipeIds = recipes.map((recipe) => recipe.id).toList();
        
        try {
          // Check which recipes are favorited by the user
          final favoriteStatuses = await favoritesDataSource.checkFavoriteStatus(recipeIds);
          
          // Update recipe models with favorite status
          for (int i = 0; i < recipes.length; i++) {
            recipes[i] = recipes[i].copyWithFavorite(favoriteStatuses[i]);
          }
        } catch (e) {
          // If checking favorites fails, continue with default (false) favorite status
          // This is a graceful degradation to ensure the main feature still works
        }
        
        return Right(recipes);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get trending recipes: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        return Right(categories);
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get categories: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(
    String category, {
    int offset = 0,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final recipes = await remoteDataSource.getRecipesByCategory(
          category,
          offset: offset,
          limit: limit,
        );
        
        // Get the recipe IDs to check favorite status
        final recipeIds = recipes.map((recipe) => recipe.id).toList();
        
        try {
          // Check which recipes are favorited by the user
          final favoriteStatuses = await favoritesDataSource.checkFavoriteStatus(recipeIds);
          
          // Update recipe models with favorite status
          for (int i = 0; i < recipes.length; i++) {
            recipes[i] = recipes[i].copyWithFavorite(favoriteStatuses[i]);
          }
        } catch (e) {
          // If checking favorites fails, continue with default favorite status
        }
        
        return Right(recipes);
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get recipes for $category: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<bool>>> checkFavoriteStatus(List<int> recipeIds) async {
    if (await networkInfo.isConnected) {
      try {
        final favoriteStatuses = await favoritesDataSource.checkFavoriteStatus(recipeIds);
        return Right(favoriteStatuses);
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to check favorite status: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
} 