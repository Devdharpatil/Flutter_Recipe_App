import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal_plan.dart';

// Define ViewMode enum here to make it available in all files importing this state
enum ViewMode {
  daily,
  weekly,
  monthly;
  
  String get label {
    switch (this) {
      case ViewMode.daily: return 'Daily';
      case ViewMode.weekly: return 'Weekly';
      case ViewMode.monthly: return 'Monthly';
    }
  }
  
  String get icon {
    switch (this) {
      case ViewMode.daily: return '📆';
      case ViewMode.weekly: return '📅';
      case ViewMode.monthly: return '🗓️';
    }
  }
}

// Regular class instead of freezed since code generation isn't set up
class MealPlanState extends Equatable {
  final bool isLoading;
  final List<MealPlan> mealPlans;
  final DateTime selectedDate;
  final Failure? failure;
  final ViewMode viewMode;
  final bool isAddingToMealPlan;
  final MealPlan? lastAddedMealPlan;

  const MealPlanState({
    required this.isLoading,
    required this.mealPlans,
    required this.selectedDate,
    this.failure,
    this.viewMode = ViewMode.weekly,
    this.isAddingToMealPlan = false,
    this.lastAddedMealPlan,
  });

  factory MealPlanState.initial() => MealPlanState(
    isLoading: false,
    mealPlans: const [],
    selectedDate: DateTime.now(),
  );
  
  MealPlanState copyWith({
    bool? isLoading,
    List<MealPlan>? mealPlans,
    DateTime? selectedDate,
    Failure? failure,
    ViewMode? viewMode,
    bool? isAddingToMealPlan,
    MealPlan? lastAddedMealPlan,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      mealPlans: mealPlans ?? this.mealPlans,
      selectedDate: selectedDate ?? this.selectedDate,
      failure: failure,  // Explicitly passing null to clear failure
      viewMode: viewMode ?? this.viewMode,
      isAddingToMealPlan: isAddingToMealPlan ?? this.isAddingToMealPlan,
      lastAddedMealPlan: lastAddedMealPlan ?? this.lastAddedMealPlan,
    );
  }
  
  @override
  List<Object?> get props => [
    isLoading,
    mealPlans,
    selectedDate,
    failure,
    viewMode,
    isAddingToMealPlan,
    lastAddedMealPlan,
  ];
} 