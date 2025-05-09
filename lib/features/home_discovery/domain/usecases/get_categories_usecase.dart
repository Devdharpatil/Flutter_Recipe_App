import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/recipe_repository.dart';

class GetCategoriesUseCase implements UseCase<List<String>, NoParams> {
  final RecipeRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return repository.getCategories();
  }
} 