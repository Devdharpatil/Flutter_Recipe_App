import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal_plan.dart';
import '../models/meal_plan_model.dart';

abstract class MealPlanDataSource {
  /// Get all meal plans for the current user
  Future<List<MealPlanModel>> getMealPlans();
  
  /// Get meal plans for a specific date range
  Future<List<MealPlanModel>> getMealPlansForDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Add a recipe to the meal plan
  Future<MealPlanModel> addToMealPlan({
    required int recipeId,
    required String recipeTitle,
    required String recipeImage,
    required DateTime date,
    required MealType mealType,
    int servings = 1,
  });
  
  /// Update an existing meal plan
  Future<MealPlanModel> updateMealPlan(MealPlanModel mealPlan);
  
  /// Delete a meal plan by ID
  Future<bool> deleteMealPlan(String mealPlanId);
  
  /// Get meal plans for a specific date
  Future<List<MealPlanModel>> getMealPlansForDate(DateTime date);
  
  /// Get meal plans for a specific recipe
  Future<List<MealPlanModel>> getMealPlansForRecipe(int recipeId);
  
  /// Checks if the meal_plans table exists
  Future<bool> checkIfTableExists();
}

class MealPlanDataSourceImpl implements MealPlanDataSource {
  final SupabaseClient supabaseClient;
  
  MealPlanDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<List<MealPlanModel>> getMealPlans() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      final response = await supabaseClient
          .from('meal_plans')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: true);
      
      return (response as List)
          .map((json) => MealPlanModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is AuthFailure) rethrow;
      
      // Check for PostgrestException with table not found error
      if (e.toString().contains('relation "public.meal_plans" does not exist') ||
          e.toString().contains('42P01')) {
        throw ServerFailure(
          message: 'Meal planning feature is not fully set up. Database table is missing.',
        );
      }
      
      throw ServerFailure(message: 'Failed to get meal plans: ${e.toString()}');
    }
  }
  
  @override
  Future<List<MealPlanModel>> getMealPlansForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      // Format dates to match PostgreSQL date format
      final formattedStartDate = startDate.toIso8601String();
      final formattedEndDate = endDate.toIso8601String();
      
      final response = await supabaseClient
          .from('meal_plans')
          .select()
          .eq('user_id', user.id)
          .gte('date', formattedStartDate)
          .lte('date', formattedEndDate)
          .order('date', ascending: true);
      
      return (response as List)
          .map((json) => MealPlanModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is AuthFailure) rethrow;
      
      // Check for PostgrestException with table not found error
      if (e.toString().contains('relation "public.meal_plans" does not exist') ||
          e.toString().contains('42P01')) {
        throw ServerFailure(
          message: 'Meal planning feature is not fully set up. Database table is missing.',
        );
      }
      
      throw ServerFailure(
        message: 'Failed to get meal plans for date range: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<MealPlanModel> addToMealPlan({
    required int recipeId,
    required String recipeTitle,
    required String recipeImage,
    required DateTime date,
    required MealType mealType,
    int servings = 1,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      // Create a new meal plan model
      final mealPlan = MealPlanModel.create(
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        recipeImage: recipeImage,
        date: date,
        mealType: mealType,
        servings: servings,
      );
      
      // Convert to JSON for Supabase
      final mealPlanJson = {
        ...mealPlan.toJson(),
        'user_id': user.id,
      };
      
      // Insert into Supabase
      final response = await supabaseClient
          .from('meal_plans')
          .insert(mealPlanJson)
          .select()
          .single();
      
      return MealPlanModel.fromJson(response);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw ServerFailure(
        message: 'Failed to add recipe to meal plan: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<MealPlanModel> updateMealPlan(MealPlanModel mealPlan) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      // Convert to JSON for Supabase
      final mealPlanJson = mealPlan.toJson();
      
      // Update in Supabase
      final response = await supabaseClient
          .from('meal_plans')
          .update(mealPlanJson)
          .eq('id', mealPlan.id)
          .eq('user_id', user.id)
          .select()
          .single();
      
      return MealPlanModel.fromJson(response);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw ServerFailure(
        message: 'Failed to update meal plan: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<bool> deleteMealPlan(String mealPlanId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      // Delete from Supabase
      await supabaseClient
          .from('meal_plans')
          .delete()
          .eq('id', mealPlanId)
          .eq('user_id', user.id);
      
      return true;
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw ServerFailure(
        message: 'Failed to delete meal plan: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<List<MealPlanModel>> getMealPlansForDate(DateTime date) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      // Format date to match PostgreSQL date format
      final formattedDate = date.toIso8601String().split('T')[0];
      
      final response = await supabaseClient
          .from('meal_plans')
          .select()
          .eq('user_id', user.id)
          .eq('date', formattedDate)
          .order('created_at', ascending: true);
      
      return (response as List)
          .map((json) => MealPlanModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw ServerFailure(
        message: 'Failed to get meal plans for date: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<List<MealPlanModel>> getMealPlansForRecipe(int recipeId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      final response = await supabaseClient
          .from('meal_plans')
          .select()
          .eq('user_id', user.id)
          .eq('recipe_id', recipeId)
          .order('date', ascending: true);
      
      return (response as List)
          .map((json) => MealPlanModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw ServerFailure(
        message: 'Failed to get meal plans for recipe: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<bool> checkIfTableExists() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'User not authenticated');
      }
      
      // Try to query the table schema
      final response = await supabaseClient.rpc(
        'check_if_table_exists',
        params: {'table_name': 'meal_plans'},
      );
      
      return response as bool;
    } catch (e) {
      // If the function doesn't exist, return false - need to create function first
      return false;
    }
  }
} 