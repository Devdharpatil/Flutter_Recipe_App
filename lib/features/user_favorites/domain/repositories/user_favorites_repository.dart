import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class UserFavoritesRepository {
  /// Gets the list of favorite recipe IDs for the current user
  Future<Either<Failure, Set<int>>> getFavoriteIds();
  
  /// Adds a recipe to favorites
  Future<Either<Failure, Unit>> addFavorite(int recipeId);
  
  /// Removes a recipe from favorites
  Future<Either<Failure, Unit>> removeFavorite(int recipeId);
} 