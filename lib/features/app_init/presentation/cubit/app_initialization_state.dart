part of 'app_initialization_cubit.dart';

enum AuthState { firstLaunch, unauthenticated, authenticated }

class AppInitializationState extends Equatable {
  final bool isInitializing;
  final bool isCompleted;
  final AuthState? authState;

  const AppInitializationState._({
    this.isInitializing = false,
    this.isCompleted = false,
    this.authState,
  });

  const AppInitializationState.initial() : this._();

  const AppInitializationState.initializing()
      : this._(isInitializing: true, isCompleted: false);

  const AppInitializationState.completed({required AuthState authState})
      : this._(isInitializing: false, isCompleted: true, authState: authState);

  @override
  List<Object?> get props => [isInitializing, isCompleted, authState];
} 