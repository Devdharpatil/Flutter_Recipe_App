import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home_discovery/domain/entities/recipe.dart';
import '../entities/filter_options.dart';

abstract class SearchRepository {
  /// Searches for recipes based on a query string and optional filters
  Future<Either<Failure, List<Recipe>>> searchRecipes({
    required String query,
    FilterOptions? filterOptions,
    int offset = 0,
    int limit = 20,
  });
  
  /// Gets autocomplete suggestions for a partial query
  Future<Either<Failure, List<String>>> getAutocompleteSuggestions(String query);
  
  /// Saves a recent search to local storage
  Future<Either<Failure, bool>> saveRecentSearch(String query);
  
  /// Gets the list of recent searches from local storage
  Future<Either<Failure, List<String>>> getRecentSearches();
} 