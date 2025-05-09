import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cooking_mode_event.dart';
import 'cooking_mode_state.dart';

class CookingModeBloc extends Bloc<CookingModeEvent, CookingModeState> {
  Timer? _timer;
  
  CookingModeBloc() : super(CookingModeInitial()) {
    on<InitializeCookingMode>(_onInitializeCookingMode);
    on<GoToNextStep>(_onGoToNextStep);
    on<GoToPreviousStep>(_onGoToPreviousStep);
    on<GoToSpecificStep>(_onGoToSpecificStep);
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<ResetTimer>(_onResetTimer);
    on<TimerTick>(_onTimerTick);
    on<ExitCookingMode>(_onExitCookingMode);
  }
  
  void _onInitializeCookingMode(
    InitializeCookingMode event,
    Emitter<CookingModeState> emit,
  ) {
    emit(CookingModeLoaded(
      recipe: event.recipe,
      currentStepIndex: 0,
    ));
  }
  
  void _onGoToNextStep(
    GoToNextStep event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      final recipe = currentState.recipe;
      final totalSteps = recipe.analyzedInstructions.length;
      
      if (currentState.currentStepIndex < totalSteps - 1) {
        // Cancel any active timer when changing steps
        _cancelTimer();
        
        emit(currentState.copyWith(
          currentStepIndex: currentState.currentStepIndex + 1,
          isTimerActive: false,
          timerRemainingSeconds: null,
        ));
      }
    }
  }
  
  void _onGoToPreviousStep(
    GoToPreviousStep event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      
      if (currentState.currentStepIndex > 0) {
        // Cancel any active timer when changing steps
        _cancelTimer();
        
        emit(currentState.copyWith(
          currentStepIndex: currentState.currentStepIndex - 1,
          isTimerActive: false,
          timerRemainingSeconds: null,
        ));
      }
    }
  }
  
  void _onGoToSpecificStep(
    GoToSpecificStep event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      final recipe = currentState.recipe;
      final totalSteps = recipe.analyzedInstructions.length;
      
      if (event.stepIndex >= 0 && event.stepIndex < totalSteps) {
        // Cancel any active timer when changing steps
        _cancelTimer();
        
        emit(currentState.copyWith(
          currentStepIndex: event.stepIndex,
          isTimerActive: false,
          timerRemainingSeconds: null,
        ));
      }
    }
  }
  
  void _onStartTimer(
    StartTimer event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      
      // Cancel any existing timer
      _cancelTimer();
      
      // Start a new timer
      emit(currentState.copyWith(
        isTimerActive: true,
        timerRemainingSeconds: event.durationInSeconds,
      ));
      
      _startTimer(event.durationInSeconds);
    }
  }
  
  void _onPauseTimer(
    PauseTimer event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      
      if (currentState.isTimerActive) {
        _cancelTimer();
        emit(currentState.copyWith(isTimerActive: false));
      }
    }
  }
  
  void _onResumeTimer(
    ResumeTimer event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      
      if (!currentState.isTimerActive && currentState.timerRemainingSeconds != null) {
        emit(currentState.copyWith(isTimerActive: true));
        _startTimer(currentState.timerRemainingSeconds!);
      }
    }
  }
  
  void _onResetTimer(
    ResetTimer event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      
      // Cancel any existing timer
      _cancelTimer();
      
      emit(currentState.copyWith(
        isTimerActive: false,
        timerRemainingSeconds: null,
      ));
    }
  }
  
  void _onTimerTick(
    TimerTick event,
    Emitter<CookingModeState> emit,
  ) {
    if (state is CookingModeLoaded) {
      final currentState = state as CookingModeLoaded;
      
      emit(currentState.copyWith(
        timerRemainingSeconds: event.remainingSeconds,
      ));
      
      // If timer reached zero, cancel it
      if (event.remainingSeconds <= 0) {
        _cancelTimer();
        emit(currentState.copyWith(isTimerActive: false));
      }
    }
  }
  
  void _onExitCookingMode(
    ExitCookingMode event,
    Emitter<CookingModeState> emit,
  ) {
    _cancelTimer();
    // No need to emit a new state as we're exiting the screen
  }
  
  void _startTimer(int durationInSeconds) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remainingSeconds = durationInSeconds - timer.tick;
      if (remainingSeconds >= 0) {
        add(TimerTick(remainingSeconds: remainingSeconds));
      } else {
        _cancelTimer();
      }
    });
  }
  
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
} 