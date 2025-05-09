import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/load_user_favorites_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import 'user_favorites_event.dart';
import 'user_favorites_state.dart';

class UserFavoritesBloc extends Bloc<UserFavoritesEvent, UserFavoritesState> {
  final LoadUserFavoritesUseCase loadUserFavoritesUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  // We'll keep a cache of the current favorites to handle optimistic updates
  Set<int> _currentFavorites = {};

  UserFavoritesBloc({
    required this.loadUserFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<UserFavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    
    final result = await loadUserFavoritesUseCase(NoParams());
    
    result.fold(
      (failure) => emit(FavoritesError(failure: failure)),
      (favoriteIds) {
        _currentFavorites = favoriteIds;
        emit(FavoritesLoaded(favoriteRecipeIds: favoriteIds));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<UserFavoritesState> emit,
  ) async {
    // Store original state for rollback if needed
    final currentState = state;
    
    if (currentState is! FavoritesLoaded) {
      // If favorites aren't loaded yet, load them first then retry
      add(const LoadFavorites());
      return;
    }

    // Create a new set to avoid modifying the original
    final newFavorites = Set<int>.from(_currentFavorites);
    
    // Optimistic update
    if (event.currentStatus) {
      // Currently favorited, so remove it
      newFavorites.remove(event.recipeId);
    } else {
      // Currently not favorited, so add it
      newFavorites.add(event.recipeId);
    }
    
    // Update the state immediately for optimistic UI update
    _currentFavorites = newFavorites;
    emit(FavoritesLoaded(favoriteRecipeIds: newFavorites));
    
    // Perform the actual server operation
    final result = event.currentStatus
        ? await removeFavoriteUseCase(RemoveFavoriteParams(recipeId: event.recipeId))
        : await addFavoriteUseCase(AddFavoriteParams(recipeId: event.recipeId));
    
    // Handle the result
    result.fold(
      (failure) {
        // Revert optimistic update on failure
        _currentFavorites = currentState.favoriteRecipeIds;
        emit(FavoritesLoaded(favoriteRecipeIds: currentState.favoriteRecipeIds));
        
        // Emit error message that can be caught by a BlocListener for a Snackbar
        emit(FavoritesActionFailure(message: failure.message));
        
        // Restore the main state
        emit(FavoritesLoaded(favoriteRecipeIds: currentState.favoriteRecipeIds));
      },
      (success) {
        // No need to update state again on success, already optimistically updated
        // But we can emit a transient success state for snackbar
        final message = event.currentStatus
            ? 'Recipe removed from favorites'
            : 'Recipe added to favorites';
        
        emit(FavoritesActionSuccess(message: message));
        
        // Restore the main state with the updated favorites
        emit(FavoritesLoaded(favoriteRecipeIds: newFavorites));
      },
    );
  }
} 