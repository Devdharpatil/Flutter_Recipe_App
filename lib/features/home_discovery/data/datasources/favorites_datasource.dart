import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';

abstract class FavoritesDataSource {
  /// Check if the recipes with the given IDs are favorites for the current user
  Future<List<bool>> checkFavoriteStatus(List<int> recipeIds);
  
  /// Toggle a recipe's favorite status
  Future<bool> toggleFavorite(int recipeId, bool isFavorite);
}

class FavoritesDataSourceImpl implements FavoritesDataSource {
  final SupabaseClient supabaseClient;
  
  FavoritesDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<List<bool>> checkFavoriteStatus(List<int> recipeIds) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return List.filled(recipeIds.length, false);
      }
      
      final response = await supabaseClient
          .from('user_favorites')
          .select('recipe_id')
          .eq('user_id', userId)
          .inFilter('recipe_id', recipeIds);
      
      final favoriteIds = (response as List)
          .map((item) => item['recipe_id'] as int)
          .toList();
          
      return recipeIds.map((id) => favoriteIds.contains(id)).toList();
    } catch (e) {
      throw ServerFailure(message: 'Failed to check favorites: $e');
    }
  }
  
  @override
  Future<bool> toggleFavorite(int recipeId, bool isFavorite) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerFailure(message: 'User not authenticated');
      }
      
      if (isFavorite) {
        // Add to favorites
        await supabaseClient.from('user_favorites').insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      } else {
        // Remove from favorites
        await supabaseClient
            .from('user_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
        return false;
      }
    } catch (e) {
      throw ServerFailure(message: 'Failed to update favorite: $e');
    }
  }
} 