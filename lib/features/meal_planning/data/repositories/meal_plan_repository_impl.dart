import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/meal_plan_datasource.dart';
import '../models/meal_plan_model.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final MealPlanDataSource dataSource;
  final NetworkInfo networkInfo;
  
  MealPlanRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<MealPlan>>> getMealPlans() async {
    if (await networkInfo.isConnected) {
      try {
        final mealPlans = await dataSource.getMealPlans();
        return Right(mealPlans);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to get meal plans: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MealPlan>>> getMealPlansForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final mealPlans = await dataSource.getMealPlansForDateRange(
          startDate, 
          endDate,
        );
        return Right(mealPlans);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to get meal plans for date range: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
  
  @override
  Future<Either<Failure, MealPlan>> addToMealPlan({
    required int recipeId,
    required String recipeTitle,
    required String recipeImage,
    required DateTime date,
    required MealType mealType,
    int servings = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final mealPlan = await dataSource.addToMealPlan(
          recipeId: recipeId,
          recipeTitle: recipeTitle,
          recipeImage: recipeImage,
          date: date,
          mealType: mealType,
          servings: servings,
        );
        return Right(mealPlan);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to add recipe to meal plan: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
  
  @override
  Future<Either<Failure, MealPlan>> updateMealPlan(MealPlan mealPlan) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert MealPlan entity to MealPlanModel if it's not already a model
        final mealPlanModel = mealPlan is MealPlanModel 
            ? mealPlan 
            : MealPlanModel(
                id: mealPlan.id,
                recipeId: mealPlan.recipeId,
                recipeTitle: mealPlan.recipeTitle,
                recipeImage: mealPlan.recipeImage,
                date: mealPlan.date,
                mealType: mealPlan.mealType,
                servings: mealPlan.servings,
                createdAt: mealPlan.createdAt,
                isFavorite: mealPlan.isFavorite,
                originalDate: mealPlan.originalDate,
              );
        
        final updatedMealPlan = await dataSource.updateMealPlan(mealPlanModel);
        return Right(updatedMealPlan);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to update meal plan: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteMealPlan(String mealPlanId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.deleteMealPlan(mealPlanId);
        return Right(result);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to delete meal plan: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MealPlan>>> getMealPlansForDate(DateTime date) async {
    if (await networkInfo.isConnected) {
      try {
        final mealPlans = await dataSource.getMealPlansForDate(date);
        return Right(mealPlans);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to get meal plans for date: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MealPlan>>> getMealPlansForRecipe(int recipeId) async {
    if (await networkInfo.isConnected) {
      try {
        final mealPlans = await dataSource.getMealPlansForRecipe(recipeId);
        return Right(mealPlans);
      } on ServerFailure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to get meal plans for recipe: ${e.toString()}',
        ));
      }
    } else {
      return Left(NetworkFailure(
        'No internet connection. Please check your connection and try again.',
      ));
    }
  }
} 