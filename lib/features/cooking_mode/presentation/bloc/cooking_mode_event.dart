import 'package:equatable/equatable.dart';
import '../../../recipe_detail/domain/entities/recipe_detail.dart';

abstract class CookingModeEvent extends Equatable {
  const CookingModeEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeCookingMode extends CookingModeEvent {
  final RecipeDetail recipe;
  
  const InitializeCookingMode({required this.recipe});
  
  @override
  List<Object> get props => [recipe];
}

class GoToNextStep extends CookingModeEvent {}

class GoToPreviousStep extends CookingModeEvent {}

class GoToSpecificStep extends CookingModeEvent {
  final int stepIndex;
  
  const GoToSpecificStep({required this.stepIndex});
  
  @override
  List<Object> get props => [stepIndex];
}

class StartTimer extends CookingModeEvent {
  final int durationInSeconds;
  
  const StartTimer({required this.durationInSeconds});
  
  @override
  List<Object> get props => [durationInSeconds];
}

class PauseTimer extends CookingModeEvent {}

class ResumeTimer extends CookingModeEvent {}

class ResetTimer extends CookingModeEvent {}

class TimerTick extends CookingModeEvent {
  final int remainingSeconds;
  
  const TimerTick({required this.remainingSeconds});
  
  @override
  List<Object> get props => [remainingSeconds];
}

class ExitCookingMode extends CookingModeEvent {} 