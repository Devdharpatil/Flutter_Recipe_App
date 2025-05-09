import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/usecases/add_to_meal_plan.dart' as usecase;
import '../../domain/usecases/get_meal_plans.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import 'meal_plan_event.dart';
import 'meal_plan_state.dart';

class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  final GetMealPlans getMealPlans;
  final usecase.AddToMealPlan addToMealPlanUseCase;
  final MealPlanRepository repository;
  
  MealPlanBloc({
    required this.getMealPlans,
    required usecase.AddToMealPlan addToMealPlan,
    required this.repository,
  }) : addToMealPlanUseCase = addToMealPlan,
       super(MealPlanState.initial()) {
    on<LoadMealPlans>(_onLoadMealPlans);
    on<ChangeSelectedDate>(_onChangeSelectedDate);
    on<ChangeViewMode>(_onChangeViewMode);
    on<AddToMealPlan>(_onAddToMealPlan);
    on<UpdateMealPlan>(_onUpdateMealPlan);
    on<DeleteMealPlan>(_onDeleteMealPlan);
    on<NavigateToDate>(_onNavigateToDate);
    on<ToggleFavoriteMealPlan>(_onToggleFavoriteMealPlan);
  }
  
  /// Handle LoadMealPlans event
  Future<void> _onLoadMealPlans(
    LoadMealPlans event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    
    // Calculate date range based on view mode
    final DateTime startDate;
    final DateTime endDate;
    
    switch (state.viewMode) {
      case ViewMode.daily:
        startDate = _stripTime(state.selectedDate);
        endDate = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
        break;
      case ViewMode.weekly:
        // Get start of week (Monday) and end of week (Sunday)
        final day = state.selectedDate.weekday;
        startDate = _stripTime(state.selectedDate.subtract(Duration(days: day - 1)));
        endDate = DateTime(
          startDate.year, 
          startDate.month, 
          startDate.day + 6, 
          23, 59, 59
        );
        break;
      case ViewMode.monthly:
        // Get first day of month and last day of month
        startDate = DateTime(state.selectedDate.year, state.selectedDate.month, 1);
        endDate = DateTime(
          state.selectedDate.year, 
          state.selectedDate.month + 1, 
          0, 
          23, 59, 59
        );
        break;
    }
    
    // Get meal plans for the date range
    final result = await getMealPlans(
      GetMealPlansParams.dateRange(
        startDate: startDate,
        endDate: endDate,
      ),
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )), 
      (mealPlans) => emit(state.copyWith(
        isLoading: false,
        mealPlans: mealPlans,
      )),
    );
  }
  
  /// Handle ChangeSelectedDate event
  void _onChangeSelectedDate(
    ChangeSelectedDate event,
    Emitter<MealPlanState> emit,
  ) {
    emit(state.copyWith(
      selectedDate: event.date,
      failure: null,
    ));
    
    // Reload meal plans for the new date
    add(const LoadMealPlans());
  }
  
  /// Handle ChangeViewMode event
  void _onChangeViewMode(
    ChangeViewMode event,
    Emitter<MealPlanState> emit,
  ) {
    emit(state.copyWith(
      viewMode: event.viewMode,
      failure: null,
    ));
    
    // Reload meal plans for the new view mode
    add(const LoadMealPlans());
  }
  
  /// Handle AddToMealPlan event
  Future<void> _onAddToMealPlan(
    AddToMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(state.copyWith(
      isAddingToMealPlan: true,
      failure: null,
    ));
    
    final result = await addToMealPlanUseCase(
      usecase.AddToMealPlanParams(
        recipeId: event.recipeId,
        recipeTitle: event.recipeTitle,
        recipeImage: event.recipeImage,
        date: event.date,
        mealType: event.mealType,
        servings: event.servings,
      ),
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        isAddingToMealPlan: false,
        failure: failure,
      )), 
      (mealPlan) {
        // Add the new meal plan to the list
        final updatedMealPlans = List<MealPlan>.from(state.mealPlans)..add(mealPlan);
        
        emit(state.copyWith(
          isAddingToMealPlan: false,
          mealPlans: updatedMealPlans,
          lastAddedMealPlan: mealPlan,
        ));
      },
    );
  }
  
  /// Handle UpdateMealPlan event
  Future<void> _onUpdateMealPlan(
    UpdateMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    
    // Store the original date for comparison
    final DateTime originalDate = _stripTime(event.mealPlan.originalDate ?? event.mealPlan.date);
    final DateTime newDate = _stripTime(event.mealPlan.date);
    final bool dateChanged = originalDate != newDate;
    
    // Call repository to update the meal plan
    final result = await repository.updateMealPlan(event.mealPlan);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )), 
      (updatedMealPlan) {
        if (dateChanged) {
          // If the date was changed, we need to reload all meal plans
          // to ensure proper filtering in the UI
          emit(state.copyWith(isLoading: false));
          add(const LoadMealPlans());
        } else {
          // If only other properties were updated, just update the list
          final updatedMealPlans = List<MealPlan>.from(state.mealPlans);
          final index = updatedMealPlans.indexWhere((mealPlan) => mealPlan.id == updatedMealPlan.id);
          
          if (index != -1) {
            updatedMealPlans[index] = updatedMealPlan;
          }
          
          emit(state.copyWith(
            isLoading: false,
            mealPlans: updatedMealPlans,
          ));
        }
      },
    );
  }
  
  /// Handle DeleteMealPlan event
  Future<void> _onDeleteMealPlan(
    DeleteMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    
    // Call repository to delete the meal plan
    final result = await repository.deleteMealPlan(event.mealPlan.id);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )), 
      (success) {
        if (success) {
          // Remove the meal plan from the list
          final updatedMealPlans = List<MealPlan>.from(state.mealPlans)
            ..removeWhere((mealPlan) => mealPlan.id == event.mealPlan.id);
          
          emit(state.copyWith(
            isLoading: false,
            mealPlans: updatedMealPlans,
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            failure: const ServerFailure(message: 'Failed to delete meal plan'),
          ));
        }
      },
    );
  }
  
  /// Handle NavigateToDate event
  void _onNavigateToDate(
    NavigateToDate event,
    Emitter<MealPlanState> emit,
  ) {
    emit(state.copyWith(
      selectedDate: event.date,
      failure: null,
    ));
    
    // Reload meal plans for the new date
    add(const LoadMealPlans());
  }
  
  /// Handle ToggleFavoriteMealPlan event
  Future<void> _onToggleFavoriteMealPlan(
    ToggleFavoriteMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    // Find all instances of this meal plan by recipe ID and toggle favorite status
    final updatedMealPlans = state.mealPlans.map((mealPlan) {
      if (mealPlan.recipeId == event.recipeId) {
        return mealPlan.copyWith(isFavorite: event.isFavorite);
      }
      return mealPlan;
    }).toList();
    
    emit(state.copyWith(
      mealPlans: updatedMealPlans,
      failure: null,
    ));
    
    // Persist favorite status to database for each affected meal plan
    for (final mealPlan in updatedMealPlans) {
      if (mealPlan.recipeId == event.recipeId) {
        // Update the meal plan in the database
        await repository.updateMealPlan(mealPlan);
      }
    }
  }
  
  /// Helper method to strip time from a DateTime
  DateTime _stripTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
} 