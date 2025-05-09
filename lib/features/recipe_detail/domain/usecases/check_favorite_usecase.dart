import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/recipe_detail_repository.dart';
import 'get_recipe_detail_usecase.dart';

class CheckFavoriteUseCase implements UseCase<bool, RecipeParams> {
  final RecipeDetailRepository repository;

  CheckFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(RecipeParams params) async {
    return await repository.isFavorite(params.recipeId);
  }
} 