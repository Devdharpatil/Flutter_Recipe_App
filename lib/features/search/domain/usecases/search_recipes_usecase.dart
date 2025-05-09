import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home_discovery/domain/entities/recipe.dart';
import '../repositories/search_repository.dart';
import '../entities/filter_options.dart';

class SearchRecipesUseCase {
  final SearchRepository repository;

  SearchRecipesUseCase(this.repository);
  
  Future<Either<Failure, List<Recipe>>> call({
    required String query,
    FilterOptions? filterOptions,
    int offset = 0,
    int limit = 20,
  }) {
    return repository.searchRecipes(
      query: query,
      filterOptions: filterOptions,
      offset: offset,
      limit: limit,
    );
  }
} 