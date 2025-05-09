import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../../../../core/config/api_config.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  /// Fetches trending recipes from Spoonacular API
  Future<List<RecipeModel>> getTrendingRecipes({int limit = 10});

  /// Fetches available meal types/categories from Spoonacular API
  Future<List<String>> getCategories();

  /// Fetches recipes for a specific category
  Future<List<RecipeModel>> getRecipesByCategory(
    String category, {
    int offset = 0,
    int limit = 20,
  });
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final http.Client client;

  RecipeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<RecipeModel>> getTrendingRecipes({int limit = 10}) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.spoonacularBaseUrl}/recipes/random?apiKey=${ApiConfig.spoonacularApiKey}&number=$limit',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final recipes = data['recipes'] as List;
        
        // Check if the API returned any recipes
        if (recipes.isEmpty) {
          // Return empty list, not an error, as this is a valid response
          return [];
        }
        
        return recipes.map((recipe) => RecipeModel.fromJson(recipe)).toList();
      } else if (response.statusCode == 402) {
        // Handle quota exceeded error specifically
        throw ServerFailure(
          message: 'API quota exceeded. Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        throw ServerFailure(
          message: 'Failed to load trending recipes. Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure(
        message: 'Failed to load trending recipes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getCategories() async {
    // For simplicity, we'll return a predefined list of categories
    // In a real app, you might fetch these from Spoonacular API
    return [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Dessert',
      'Appetizer',
      'Salad',
      'Soup',
      'Snack',
      'Beverage',
      'Vegan',
      'Vegetarian',
      'Gluten-Free',
    ];
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(
    String category, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.spoonacularBaseUrl}/recipes/complexSearch?apiKey=${ApiConfig.spoonacularApiKey}&type=$category&offset=$offset&number=$limit',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((recipe) => RecipeModel.fromJson(recipe)).toList();
      } else {
        throw ServerFailure(
          message: 'Failed to load recipes for $category',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure(
        message: 'Failed to load recipes for $category: ${e.toString()}',
      );
    }
  }
} 