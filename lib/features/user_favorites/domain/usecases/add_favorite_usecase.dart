import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_favorites_repository.dart';

class AddFavoriteUseCase implements UseCase<Unit, AddFavoriteParams> {
  final UserFavoritesRepository repository;

  AddFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AddFavoriteParams params) async {
    return await repository.addFavorite(params.recipeId);
  }
}

class AddFavoriteParams extends Equatable {
  final int recipeId;

  const AddFavoriteParams({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
} 