import 'package:dartz/dartz.dart';

abstract class UserFavoritesDataSource {
  /// Gets the list of favorite recipe IDs for the current user
  Future<Set<int>> getFavoriteIds();
  
  /// Adds a recipe to favorites
  Future<Unit> addFavorite(int recipeId);
  
  /// Removes a recipe from favorites
  Future<Unit> removeFavorite(int recipeId);
} 