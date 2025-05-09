import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_initialization_state.dart';

class AppInitializationCubit extends Cubit<AppInitializationState> {
  final SharedPreferences _sharedPreferences;
  final SupabaseClient _supabaseClient;

  AppInitializationCubit({
    required SharedPreferences sharedPreferences,
    required SupabaseClient supabaseClient,
  })  : _sharedPreferences = sharedPreferences,
        _supabaseClient = supabaseClient,
        super(const AppInitializationState.initial());

  Future<void> initializeApp() async {
    emit(const AppInitializationState.initializing());

    try {
      // Check if this is the first launch
      final isFirstLaunch = !(_sharedPreferences.getBool('app_initialized') ?? false);

      // Check if we have a Supabase session
      final session = _supabaseClient.auth.currentSession;
      final isAuthenticated = session != null && !session.isExpired;

      // Delay for splash screen visibility (at least 1.5 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));

      // Determine next screen
      if (isFirstLaunch) {
        // First launch -> go to onboarding
        emit(const AppInitializationState.completed(
          authState: AuthState.firstLaunch,
        ));
        _sharedPreferences.setBool('app_initialized', true);
      } else if (isAuthenticated) {
        // User is logged in -> go to home
        emit(const AppInitializationState.completed(
          authState: AuthState.authenticated,
        ));
      } else {
        // Not first launch but not logged in -> go to auth hub
        emit(const AppInitializationState.completed(
          authState: AuthState.unauthenticated,
        ));
      }
    } catch (e) {
      // On error, assume unauthenticated for safety
      emit(const AppInitializationState.completed(
        authState: AuthState.unauthenticated,
      ));
    }
  }
} 