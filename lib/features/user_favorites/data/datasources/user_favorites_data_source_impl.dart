import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import 'user_favorites_data_source.dart';

class UserFavoritesDataSourceImpl implements UserFavoritesDataSource {
  final SupabaseClient supabaseClient;

  UserFavoritesDataSourceImpl({required this.supabaseClient});

  @override
  Future<Set<int>> getFavoriteIds() async {
    try {
      // Get the current user's ID
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException(message: 'User not logged in');
      }

      // Fetch favorites from Supabase
      final response = await supabaseClient
          .from('user_favorites')
          .select('recipe_id')
          .eq('user_id', currentUser.id);

      // Convert response to Set<int>
      final favoriteIds = (response as List)
          .map((item) => item['recipe_id'] as int)
          .toSet();

      return favoriteIds;
    } catch (e) {
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Unit> addFavorite(int recipeId) async {
    try {
      // Get the current user's ID
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException(message: 'User not logged in');
      }

      // Add to Supabase
      await supabaseClient.from('user_favorites').insert({
        'user_id': currentUser.id,
        'recipe_id': recipeId,
      });

      return unit;
    } catch (e) {
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Unit> removeFavorite(int recipeId) async {
    try {
      // Get the current user's ID
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException(message: 'User not logged in');
      }

      // Remove from Supabase
      await supabaseClient
          .from('user_favorites')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('recipe_id', recipeId);

      return unit;
    } catch (e) {
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
} 