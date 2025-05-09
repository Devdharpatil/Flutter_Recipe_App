import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/recipe_detail_repository.dart';

class ToggleFavoriteUseCase implements UseCase<bool, FavoriteParams> {
  final RecipeDetailRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(FavoriteParams params) async {
    return await repository.toggleFavorite(params.recipeId, params.currentStatus);
  }
}

class FavoriteParams extends Equatable {
  final int recipeId;
  final bool currentStatus;

  const FavoriteParams({
    required this.recipeId,
    required this.currentStatus,
  });

  @override
  List<Object> get props => [recipeId, currentStatus];
} 