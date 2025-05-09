import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/theme_service.dart';
import '../../domain/usecases/get_app_settings_usecase.dart';
import '../../domain/usecases/update_app_settings_usecase.dart';

// Event classes
abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

class AppSettingsFetched extends AppSettingsEvent {
  const AppSettingsFetched();
}

class ThemeChanged extends AppSettingsEvent {
  final ThemeMode themeMode;

  const ThemeChanged({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

// State classes
abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object?> get props => [];
}

class AppSettingsInitial extends AppSettingsState {
  const AppSettingsInitial();
}

class AppSettingsLoading extends AppSettingsState {
  const AppSettingsLoading();
}

class AppSettingsLoaded extends AppSettingsState {
  final ThemeMode themeMode;

  const AppSettingsLoaded({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class AppSettingsError extends AppSettingsState {
  final String message;
  final ThemeMode? themeMode;

  const AppSettingsError({required this.message, this.themeMode});

  @override
  List<Object?> get props => [message, themeMode];
}

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final GetAppSettingsUseCase getAppSettings;
  final UpdateAppSettingsUseCase updateAppSettings;
  final ThemeService themeService;

  AppSettingsBloc({
    required this.getAppSettings,
    required this.updateAppSettings,
    required this.themeService,
  }) : super(const AppSettingsInitial()) {
    on<AppSettingsFetched>(_onAppSettingsFetched);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onAppSettingsFetched(
    AppSettingsFetched event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(const AppSettingsLoading());

    final result = await getAppSettings();
    
    result.fold(
      (failure) => emit(AppSettingsError(message: _mapFailureToMessage(failure))),
      (settings) {
        final themeMode = _parseThemeMode(settings.themePreference);
        // Update the theme service with the loaded theme mode
        themeService.setThemeMode(themeMode);
        emit(AppSettingsLoaded(themeMode: themeMode));
      },
    );
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    // Immediately update the theme service for a responsive feel
    themeService.setThemeMode(event.themeMode);
    
    // Emit the updated state
    emit(AppSettingsLoaded(themeMode: event.themeMode));

    // Perform the update in the background
    final result = await updateAppSettings(
      UpdateAppSettingsParams(
        themePreference: _themePreferenceFromMode(event.themeMode),
      ),
    );
    
    // Handle result - only show error if something went wrong
    result.fold(
      (failure) => emit(AppSettingsError(
        message: _mapFailureToMessage(failure),
        themeMode: event.themeMode, // Keep the new theme mode even if save failed
      )), 
      (_) => {}, // Do nothing on success as we've already updated the UI
    );
  }

  ThemeMode _parseThemeMode(String preference) {
    switch (preference.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themePreferenceFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
      default:
        return 'system';
    }
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