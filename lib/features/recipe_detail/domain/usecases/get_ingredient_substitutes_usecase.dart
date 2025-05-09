import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ingredient_substitutes.dart';
import '../repositories/recipe_detail_repository.dart';

class GetIngredientSubstitutesUseCase implements UseCase<IngredientSubstitutes, IngredientNameParams> {
  final RecipeDetailRepository repository;

  GetIngredientSubstitutesUseCase(this.repository);

  @override
  Future<Either<Failure, IngredientSubstitutes>> call(IngredientNameParams params) async {
    return await repository.getIngredientSubstitutes(params.ingredientName);
  }
}

class IngredientNameParams extends Equatable {
  final String ingredientName;

  const IngredientNameParams({required this.ingredientName});

  @override
  List<Object> get props => [ingredientName];
} 