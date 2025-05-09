import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

/// Use case for getting meal plans for a date range
class GetMealPlans implements UseCase<List<MealPlan>, GetMealPlansParams> {
  final MealPlanRepository repository;
  
  GetMealPlans(this.repository);
  
  @override
  Future<Either<Failure, List<MealPlan>>> call(GetMealPlansParams params) {
    if (params.startDate != null && params.endDate != null) {
      return repository.getMealPlansForDateRange(params.startDate!, params.endDate!);
    } else if (params.date != null) {
      return repository.getMealPlansForDate(params.date!);
    } else if (params.recipeId != null) {
      return repository.getMealPlansForRecipe(params.recipeId!);
    } else {
      return repository.getMealPlans();
    }
  }
}

/// Parameters for the [GetMealPlans] use case
class GetMealPlansParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? date;
  final int? recipeId;
  
  /// Constructor for all meal plans (no filters)
  const GetMealPlansParams.all() : 
    startDate = null, 
    endDate = null, 
    date = null, 
    recipeId = null;
  
  /// Constructor for meal plans in a date range
  const GetMealPlansParams.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) : 
    startDate = startDate, 
    endDate = endDate, 
    date = null, 
    recipeId = null;
  
  /// Constructor for meal plans on a specific date
  const GetMealPlansParams.date({
    required DateTime date,
  }) : 
    startDate = null, 
    endDate = null, 
    date = date, 
    recipeId = null;
  
  /// Constructor for meal plans for a specific recipe
  const GetMealPlansParams.recipe({
    required int recipeId,
  }) : 
    startDate = null, 
    endDate = null, 
    date = null, 
    recipeId = recipeId;
  
  @override
  List<Object?> get props => [startDate, endDate, date, recipeId];
} 