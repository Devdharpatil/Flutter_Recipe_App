import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/user_favorites_repository.dart';
import '../datasources/user_favorites_data_source.dart';

class UserFavoritesRepositoryImpl implements UserFavoritesRepository {
  final UserFavoritesDataSource dataSource;
  final NetworkInfo networkInfo;

  UserFavoritesRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Set<int>>> getFavoriteIds() async {
    if (await networkInfo.isConnected) {
      try {
        final favoriteIds = await dataSource.getFavoriteIds();
        return Right(favoriteIds);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(UserNotFoundFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(int recipeId) async {
    if (await networkInfo.isConnected) {
      try {
        await dataSource.addFavorite(recipeId);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(UserNotFoundFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int recipeId) async {
    if (await networkInfo.isConnected) {
      try {
        await dataSource.removeFavorite(recipeId);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(UserNotFoundFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }
}