import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../../../../core/config/api_config.dart';
import '../../../home_discovery/data/models/recipe_model.dart';
import '../../domain/entities/filter_options.dart';

abstract class SearchRemoteDataSource {
  /// Searches for recipes based on a query string and optional filters
  Future<List<RecipeModel>> searchRecipes({
    required String query,
    FilterOptions? filterOptions,
    int offset = 0,
    int limit = 20,
  });
  
  /// Gets autocomplete suggestions for a partial query
  Future<List<String>> getAutocompleteSuggestions(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final http.Client client;

  SearchRemoteDataSourceImpl({required this.client});

  @override
  Future<List<RecipeModel>> searchRecipes({
    required String query,
    FilterOptions? filterOptions,
    int offset = 0,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'apiKey': ApiConfig.spoonacularApiKey,
      'query': query,
      'offset': offset.toString(),
      'number': limit.toString(),
      'addRecipeInformation': 'true',
      'fillIngredients': 'true',
    };
    
    // Add filter parameters if provided
    if (filterOptions != null) {
      if (filterOptions.diets.isNotEmpty) {
        queryParams['diet'] = filterOptions.diets.join(',');
      }
      
      if (filterOptions.mealTypes.isNotEmpty) {
        queryParams['type'] = filterOptions.mealTypes.join(',');
      }
      
      if (filterOptions.intolerances.isNotEmpty) {
        queryParams['intolerances'] = filterOptions.intolerances
            .map((e) => e.toLowerCase())
            .join(',');
      }
      
      if (filterOptions.cuisines.isNotEmpty) {
        queryParams['cuisine'] = filterOptions.cuisines
            .map((e) => e.toLowerCase())
            .join(',');
      }
      
      if (filterOptions.maxReadyTime != null) {
        queryParams['maxReadyTime'] = filterOptions.maxReadyTime.toString();
      }
      
      if (filterOptions.includeIngredients.isNotEmpty) {
        queryParams['includeIngredients'] = filterOptions.includeIngredients.join(',');
      }
      
      if (filterOptions.excludeIngredients.isNotEmpty) {
        queryParams['excludeIngredients'] = filterOptions.excludeIngredients.join(',');
      }
      
      if (filterOptions.calorieRange != null) {
        queryParams['minCalories'] = filterOptions.calorieRange!.start.toInt().toString();
        queryParams['maxCalories'] = filterOptions.calorieRange!.end.toInt().toString();
      }
      
      if (filterOptions.proteinRange != null) {
        queryParams['minProtein'] = filterOptions.proteinRange!.start.toInt().toString();
        queryParams['maxProtein'] = filterOptions.proteinRange!.end.toInt().toString();
      }
      
      if (filterOptions.carbsRange != null) {
        queryParams['minCarbs'] = filterOptions.carbsRange!.start.toInt().toString();
        queryParams['maxCarbs'] = filterOptions.carbsRange!.end.toInt().toString();
      }
      
      if (filterOptions.fatRange != null) {
        queryParams['minFat'] = filterOptions.fatRange!.start.toInt().toString();
        queryParams['maxFat'] = filterOptions.fatRange!.end.toInt().toString();
      }
    }
    
    final uri = Uri.parse('${ApiConfig.spoonacularBaseUrl}/recipes/complexSearch').replace(
      queryParameters: queryParams,
    );
    
    final response = await client.get(uri);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((recipe) => RecipeModel.fromJson(recipe)).toList();
    } else {
      throw ServerFailure(
        message: 'Failed to search recipes',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.length < 2) return [];
    
    final uri = Uri.parse(
      '${ApiConfig.spoonacularBaseUrl}/recipes/autocomplete?apiKey=${ApiConfig.spoonacularApiKey}&query=$query&number=10',
    );
    
    final response = await client.get(uri);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['title'] as String).toList();
    } else {
      throw ServerFailure(
        message: 'Failed to get autocomplete suggestions',
        statusCode: response.statusCode,
      );
    }
  }
} 