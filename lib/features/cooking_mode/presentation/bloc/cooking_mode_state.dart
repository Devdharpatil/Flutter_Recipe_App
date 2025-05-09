import 'package:equatable/equatable.dart';
import '../../../recipe_detail/domain/entities/recipe_detail.dart';

abstract class CookingModeState extends Equatable {
  const CookingModeState();
  
  @override
  List<Object?> get props => [];
}

class CookingModeInitial extends CookingModeState {}

class CookingModeLoading extends CookingModeState {}

class CookingModeLoaded extends CookingModeState {
  final RecipeDetail recipe;
  final int currentStepIndex;
  final bool isTimerActive;
  final int? timerRemainingSeconds;
  
  const CookingModeLoaded({
    required this.recipe,
    this.currentStepIndex = 0,
    this.isTimerActive = false,
    this.timerRemainingSeconds,
  });
  
  CookingModeLoaded copyWith({
    RecipeDetail? recipe,
    int? currentStepIndex,
    bool? isTimerActive,
    int? timerRemainingSeconds,
  }) {
    return CookingModeLoaded(
      recipe: recipe ?? this.recipe,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      timerRemainingSeconds: timerRemainingSeconds ?? this.timerRemainingSeconds,
    );
  }
  
  @override
  List<Object?> get props => [
    recipe,
    currentStepIndex,
    isTimerActive,
    timerRemainingSeconds,
  ];
}

class CookingModeError extends CookingModeState {
  final String message;
  
  const CookingModeError({required this.message});
  
  @override
  List<Object> get props => [message];
} 