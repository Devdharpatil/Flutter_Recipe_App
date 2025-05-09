import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesByCategoryUseCase implements UseCase<List<Recipe>, CategoryParams> {
  final RecipeRepository repository;

  GetRecipesByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(CategoryParams params) {
    return repository.getRecipesByCategory(
      params.category,
      offset: params.offset,
      limit: params.limit,
    );
  }
}

class CategoryParams extends Equatable {
  final String category;
  final int offset;
  final int limit;

  const CategoryParams({
    required this.category,
    this.offset = 0,
    this.limit = 20,
  });

  @override
  List<Object> get props => [category, offset, limit];
} 