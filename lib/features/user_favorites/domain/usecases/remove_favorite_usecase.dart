import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_favorites_repository.dart';

class RemoveFavoriteUseCase implements UseCase<Unit, RemoveFavoriteParams> {
  final UserFavoritesRepository repository;

  RemoveFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RemoveFavoriteParams params) async {
    return await repository.removeFavorite(params.recipeId);
  }
}

class RemoveFavoriteParams extends Equatable {
  final int recipeId;

  const RemoveFavoriteParams({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
} 