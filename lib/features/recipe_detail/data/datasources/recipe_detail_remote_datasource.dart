import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/recipe_detail_model.dart';
import '../models/ingredient_substitutes_model.dart';

abstract class RecipeDetailRemoteDataSource {
  /// Calls the Spoonacular API /recipes/{id}/information endpoint
  /// Throws [ServerException] for all server-related errors
  Future<RecipeDetailModel> getRecipeDetail(int recipeId);
  
  /// Calls the Spoonacular API /recipes/{id}/analyzedInstructions endpoint
  /// to get detailed step-by-step instructions with ingredients and equipment
  /// Throws [ServerException] for all server-related errors
  Future<List<InstructionStepModel>> getAnalyzedInstructions(int recipeId);
  
  /// Calls the Spoonacular API /food/ingredients/substitutes endpoint
  /// to get substitutes for an ingredient
  /// Throws [ServerException] for all server-related errors
  Future<IngredientSubstitutesModel> getIngredientSubstitutes(String ingredientName);
}

class RecipeDetailRemoteDataSourceImpl implements RecipeDetailRemoteDataSource {
  final http.Client client;

  RecipeDetailRemoteDataSourceImpl({required this.client});
  
  @override
  Future<RecipeDetailModel> getRecipeDetail(int recipeId) async {
    final url = Uri.parse(
      '${ApiConfig.spoonacularBaseUrl}/recipes/$recipeId/information?includeNutrition=true&apiKey=${ApiConfig.spoonacularApiKey}'
    );
    
    try {
      print('🍲 Fetching recipe details for ID: $recipeId');
      print('🔗 URL: $url');
    
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

      print('📊 Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Successfully fetched recipe data');
        try {
          return RecipeDetailModel.fromJson(responseData);
        } catch (e) {
          print('❌ Error parsing recipe data: $e');
          throw ServerException(message: 'Error parsing recipe data: $e');
        }
    } else if (response.statusCode == 404) {
        print('❌ Recipe not found');
      throw NotFoundException(message: 'Recipe not found');
      } else if (response.statusCode == 402) {
        print('❌ API quota exceeded');
        throw ServerException(message: 'API quota exceeded. Please try again later.');
      } else if (response.statusCode == 401) {
        print('❌ Invalid API key');
        throw ServerException(message: 'Invalid API key. Please check your configuration.');
    } else {
        print('❌ Server error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw ServerException(
          message: 'Failed to load recipe details (Status: ${response.statusCode})',
          statusCode: response.statusCode
        );
      }
    } catch (e) {
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      print('❌ Network or unexpected error: $e');
      throw ServerException(message: 'Failed to connect to the server: $e');
    }
  }

  @override
  Future<List<InstructionStepModel>> getAnalyzedInstructions(int recipeId) async {
    final url = Uri.parse(
      '${ApiConfig.spoonacularBaseUrl}/recipes/$recipeId/analyzedInstructions?apiKey=${ApiConfig.spoonacularApiKey}'
    );
    
    try {
      print('📝 Fetching analyzed instructions for recipe ID: $recipeId');
      print('🔗 URL: $url');
    
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

      print('📊 Instructions response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
        try {
      final List<dynamic> jsonResponse = json.decode(response.body);
          print('✅ Successfully fetched instructions data: ${jsonResponse.length} sections');
          
      if (jsonResponse.isEmpty) {
            print('ℹ️ No instructions available for this recipe');
        return [];
      }
      
      List<InstructionStepModel> steps = [];
      // Parse the response which is a list of instruction sections
      for (var section in jsonResponse) {
            if (section['steps'] == null) {
              print('⚠️ Missing steps in section: $section');
              continue;
            }
            
        final List<dynamic> stepsJson = section['steps'];
            print('ℹ️ Processing ${stepsJson.length} steps from section');
            
        steps.addAll(
          stepsJson.map((step) => InstructionStepModel.fromJson(step)).toList()
        );
      }
      return steps;
        } catch (e) {
          print('❌ Error parsing instructions data: $e');
          throw ServerException(message: 'Error parsing recipe instructions: $e');
        }
      } else if (response.statusCode == 404) {
        print('❌ Instructions not found');
        return []; // Return empty list instead of throwing error for 404
      } else if (response.statusCode == 402) {
        print('❌ API quota exceeded for instructions');
        throw ServerException(message: 'API quota exceeded. Please try again later.');
      } else {
        print('❌ Server error for instructions: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw ServerException(
          message: 'Failed to load recipe instructions (Status: ${response.statusCode})',
          statusCode: response.statusCode
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      print('❌ Network or unexpected error in instructions: $e');
      throw ServerException(message: 'Failed to load recipe instructions: $e');
    }
  }
  
  @override
  Future<IngredientSubstitutesModel> getIngredientSubstitutes(String ingredientName) async {
    final encodedName = Uri.encodeComponent(ingredientName);
    final url = Uri.parse(
      '${ApiConfig.spoonacularBaseUrl}/food/ingredients/substitutes?ingredientName=$encodedName&apiKey=${ApiConfig.spoonacularApiKey}'
    );
    
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return IngredientSubstitutesModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'No substitutes found for this ingredient');
    } else {
      throw ServerException(message: 'Failed to load ingredient substitutes');
    }
  }
} 