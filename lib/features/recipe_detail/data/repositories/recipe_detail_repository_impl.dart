import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/recipe_detail.dart';
import '../../domain/entities/ingredient_substitutes.dart';
import '../../domain/repositories/recipe_detail_repository.dart';
import '../datasources/recipe_detail_remote_datasource.dart';
import '../datasources/recipe_detail_local_datasource.dart';
import '../models/recipe_detail_model.dart';

class RecipeDetailRepositoryImpl implements RecipeDetailRepository {
  final RecipeDetailRemoteDataSource remoteDataSource;
  final RecipeDetailLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RecipeDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, RecipeDetail>> getRecipeDetail(int recipeId) async {
    if (await networkInfo.isConnected) {
      try {
        print('📱 Repository: Fetching recipe detail for ID: $recipeId');
        
        // Fetch base recipe details from API
        RecipeDetailModel recipeModel;
        try {
          recipeModel = await remoteDataSource.getRecipeDetail(recipeId);
          print('📱 Repository: Successfully fetched base recipe data');
        } catch (e) {
          print('📱 Repository: Error fetching recipe detail: $e');
          if (e is NotFoundException) {
            return Left(NotFoundFailure(message: e.message));
          } else if (e is ServerException) {
            return Left(ServerFailure(message: e.message));
          }
          return Left(ServerFailure(message: 'Failed to load recipe details: $e'));
        }
        
        // Fetch analyzed instructions from API - don't let this fail the whole request
        List<InstructionStepModel> instructions = [];
        try {
          instructions = await remoteDataSource.getAnalyzedInstructions(recipeId);
          print('📱 Repository: Successfully fetched instructions: ${instructions.length} steps');
        } catch (e) {
          print('📱 Repository: Error fetching instructions: $e');
          // Don't fail the whole request if instructions can't be fetched
        }
        
        // Check if recipe is in favorites
        bool isFavorite = false;
        try {
          isFavorite = await localDataSource.isFavorite(recipeId);
          print('📱 Repository: Favorite status: $isFavorite');
        } catch (e) {
          print('📱 Repository: Error checking favorite status: $e');
          // Don't fail if we can't check favorite status
        }

        // Combine all data into a single RecipeDetail model
        final combinedRecipe = recipeModel.copyWith(
          analyzedInstructions: instructions,
          isFavorite: isFavorite,
        );
        
        print('📱 Repository: Returning complete recipe detail');
        return Right(combinedRecipe);
      } catch (e) {
        print('📱 Repository: Unexpected error: $e');
        return Left(ServerFailure(message: 'Unexpected error occurred: $e'));
      }
    } else {
      print('📱 Repository: No internet connection');
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(int recipeId, bool currentStatus) async {
    try {
      final newStatus = await localDataSource.toggleFavorite(recipeId, currentStatus);
      return Right(newStatus);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int recipeId) async {
    try {
      final status = await localDataSource.isFavorite(recipeId);
      return Right(status);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, IngredientSubstitutes>> getIngredientSubstitutes(String ingredientName) async {
    if (await networkInfo.isConnected) {
      try {
        final substitutesModel = await remoteDataSource.getIngredientSubstitutes(ingredientName);
        return Right(substitutesModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get ingredient substitutes'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
} 