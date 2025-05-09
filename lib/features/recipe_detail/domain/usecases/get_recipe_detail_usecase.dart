import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recipe_detail.dart';
import '../repositories/recipe_detail_repository.dart';

class GetRecipeDetailUseCase implements UseCase<RecipeDetail, RecipeParams> {
  final RecipeDetailRepository repository;

  GetRecipeDetailUseCase(this.repository);

  @override
  Future<Either<Failure, RecipeDetail>> call(RecipeParams params) async {
    return await repository.getRecipeDetail(params.recipeId);
  }
}

class RecipeParams extends Equatable {
  final int recipeId;

  const RecipeParams({required this.recipeId});

  @override
  List<Object> get props => [recipeId];
} 