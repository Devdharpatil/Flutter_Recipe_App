import 'package:dartz/dartz.dart';
import 'package:recipe2/core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../home_discovery/domain/entities/recipe.dart';
import '../datasources/search_remote_datasource.dart';
import '../datasources/search_local_datasource.dart';
import '../../../home_discovery/data/datasources/favorites_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;
  final FavoritesDataSource favoritesDataSource;
  final NetworkInfo networkInfo;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.favoritesDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipes({
    required String query,
    FilterOptions? filterOptions,
    int offset = 0,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final recipeModels = await remoteDataSource.searchRecipes(
          query: query,
          filterOptions: filterOptions,
          offset: offset,
          limit: limit,
        );
        
        if (recipeModels.isEmpty) {
          return const Right([]);
        }
        
        // Get the list of recipe IDs to check for favorites
        final recipeIds = recipeModels.map((recipe) => recipe.id).toList();
        
        // Check favorite status for all recipes
        try {
          final favoriteStatuses = await favoritesDataSource.checkFavoriteStatus(recipeIds);
          
          // Combine the recipes with their favorite status
          final recipesWithFavorites = List.generate(recipeModels.length, (index) {
            final recipe = recipeModels[index];
            final isFavorite = index < favoriteStatuses.length ? favoriteStatuses[index] : false;
            return recipe.copyWithFavorite(isFavorite);
          });
          
          return Right(recipesWithFavorites);
        } catch (_) {
          // If favorite check fails, return recipes without favorite status
          return Right(recipeModels);
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAutocompleteSuggestions(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final suggestions = await remoteDataSource.getAutocompleteSuggestions(query);
        return Right(suggestions);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveRecentSearch(String query) async {
    try {
      final result = await localDataSource.saveRecentSearch(query);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    try {
      final searches = await localDataSource.getRecentSearches();
      return Right(searches);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
} 