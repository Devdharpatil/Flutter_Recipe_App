import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';

abstract class RecipeDetailLocalDataSource {
  /// Gets the favorite status of a specific recipe
  /// Throws [CacheException] if something goes wrong
  Future<bool> isFavorite(int recipeId);
  
  /// Toggles the favorite status of a recipe
  /// Returns the new favorite status
  /// Throws [CacheException] if something goes wrong
  Future<bool> toggleFavorite(int recipeId, bool currentStatus);
  
  /// Gets all favorite recipe IDs
  /// Throws [CacheException] if something goes wrong
  Future<List<int>> getFavoriteRecipes();
}

class RecipeDetailLocalDataSourceImpl implements RecipeDetailLocalDataSource {
  final SupabaseClient supabaseClient;
  
  RecipeDetailLocalDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<bool> isFavorite(int recipeId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return false; // Not logged in, so not a favorite
      }
      
      final response = await supabaseClient
          .from('user_favorites')
          .select('recipe_id')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      throw CacheException(message: 'Failed to check favorite status: $e');
    }
  }
  
  @override
  Future<bool> toggleFavorite(int recipeId, bool currentStatus) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw CacheException(message: 'User not authenticated');
      }
      
      final newStatus = !currentStatus;
      
      if (newStatus) {
        // Add to favorites
        await supabaseClient.from('user_favorites').insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Remove from favorites
        await supabaseClient
            .from('user_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
      }
      
      return newStatus;
    } catch (e) {
      throw CacheException(message: 'Failed to update favorite status: $e');
    }
  }
  
  @override
  Future<List<int>> getFavoriteRecipes() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return []; // Not logged in, so no favorites
      }
      
      final response = await supabaseClient
          .from('user_favorites')
          .select('recipe_id')
          .eq('user_id', userId);
      
      return (response as List)
          .map((item) => item['recipe_id'] as int)
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get favorites: $e');
    }
  }
} 