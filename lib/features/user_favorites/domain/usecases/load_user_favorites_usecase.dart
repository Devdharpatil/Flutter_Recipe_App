import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_favorites_repository.dart';

class LoadUserFavoritesUseCase implements UseCase<Set<int>, NoParams> {
  final UserFavoritesRepository repository;

  LoadUserFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, Set<int>>> call(NoParams params) async {
    return await repository.getFavoriteIds();
  }
} 