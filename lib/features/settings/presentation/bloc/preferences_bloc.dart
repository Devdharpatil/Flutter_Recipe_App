import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/get_user_preferences_usecase.dart';
import '../../domain/usecases/update_user_preferences_usecase.dart';

// Event classes
abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];
}

class PreferencesFetched extends PreferencesEvent {
  const PreferencesFetched();
}

class PreferencesUpdateRequested extends PreferencesEvent {
  final List<String> dietaryPreferences;
  final List<String> cookingGoals;

  const PreferencesUpdateRequested({
    required this.dietaryPreferences,
    required this.cookingGoals,
  });

  @override
  List<Object?> get props => [dietaryPreferences, cookingGoals];
}

// State classes
abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object?> get props => [];
}

class PreferencesInitial extends PreferencesState {
  const PreferencesInitial();
}

class PreferencesLoading extends PreferencesState {
  const PreferencesLoading();
}

class PreferencesLoaded extends PreferencesState {
  final List<String> dietaryPreferences;
  final List<String> cookingGoals;

  const PreferencesLoaded({
    required this.dietaryPreferences,
    required this.cookingGoals,
  });

  @override
  List<Object?> get props => [dietaryPreferences, cookingGoals];
}

class PreferencesUpdating extends PreferencesState {
  final List<String> dietaryPreferences;
  final List<String> cookingGoals;

  const PreferencesUpdating({
    required this.dietaryPreferences,
    required this.cookingGoals,
  });

  @override
  List<Object?> get props => [dietaryPreferences, cookingGoals];
}

class PreferencesUpdated extends PreferencesState {
  final List<String> dietaryPreferences;
  final List<String> cookingGoals;

  const PreferencesUpdated({
    required this.dietaryPreferences,
    required this.cookingGoals,
  });

  @override
  List<Object?> get props => [dietaryPreferences, cookingGoals];
}

class PreferencesError extends PreferencesState {
  final String message;
  final List<String>? dietaryPreferences;
  final List<String>? cookingGoals;

  const PreferencesError({
    required this.message,
    this.dietaryPreferences,
    this.cookingGoals,
  });

  @override
  List<Object?> get props => [message, dietaryPreferences, cookingGoals];
}

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetUserPreferencesUseCase getUserPreferences;
  final UpdateUserPreferencesUseCase updateUserPreferences;

  PreferencesBloc({
    required this.getUserPreferences,
    required this.updateUserPreferences,
  }) : super(const PreferencesInitial()) {
    on<PreferencesFetched>(_onPreferencesFetched);
    on<PreferencesUpdateRequested>(_onPreferencesUpdateRequested);
  }

  Future<void> _onPreferencesFetched(
    PreferencesFetched event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(const PreferencesLoading());

    final result = await getUserPreferences();
    
    emit(result.fold(
      (failure) => PreferencesError(message: _mapFailureToMessage(failure)),
      (preferences) => PreferencesLoaded(
        dietaryPreferences: preferences.dietaryPrefs,
        cookingGoals: preferences.cookingGoals,
      ),
    ));
  }

  Future<void> _onPreferencesUpdateRequested(
    PreferencesUpdateRequested event,
    Emitter<PreferencesState> emit,
  ) async {
    // First emit updating state
    emit(PreferencesUpdating(
      dietaryPreferences: event.dietaryPreferences,
      cookingGoals: event.cookingGoals,
    ));

    // Perform the update
    final result = await updateUserPreferences(
      UpdateUserPreferencesParams(
        dietaryPrefs: event.dietaryPreferences,
        cookingGoals: event.cookingGoals,
      ),
    );
    
    // Handle result
    emit(result.fold(
      (failure) => PreferencesError(
        message: _mapFailureToMessage(failure),
        dietaryPreferences: event.dietaryPreferences,
        cookingGoals: event.cookingGoals,
      ), 
      (updatedPreferences) => PreferencesUpdated(
        dietaryPreferences: updatedPreferences.dietaryPrefs,
        cookingGoals: updatedPreferences.cookingGoals,
      ),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
} 