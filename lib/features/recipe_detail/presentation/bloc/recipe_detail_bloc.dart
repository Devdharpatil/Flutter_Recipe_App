import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recipe_detail.dart';
import '../../domain/usecases/get_recipe_detail_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'recipe_detail_event.dart';
import 'recipe_detail_state.dart';

class RecipeDetailBloc extends Bloc<RecipeDetailEvent, RecipeDetailState> {
  final GetRecipeDetailUseCase getRecipeDetail;
  final ToggleFavoriteUseCase toggleFavorite;

  RecipeDetailBloc({
    required this.getRecipeDetail,
    required this.toggleFavorite,
  }) : super(const RecipeDetailInitial()) {
    on<FetchRecipeDetail>(_onFetchRecipeDetail);
    on<ToggleFavoriteRecipe>(_onToggleFavoriteRecipe);
    on<RefreshRecipeDetail>(_onRefreshRecipeDetail);
  }

  Future<void> _onFetchRecipeDetail(
    FetchRecipeDetail event,
    Emitter<RecipeDetailState> emit,
  ) async {
    emit(const RecipeDetailLoading());
    
    final result = await getRecipeDetail(RecipeParams(recipeId: event.recipeId));
    
    result.fold(
      (failure) => emit(RecipeDetailError(failure: failure)),
      (recipe) => emit(RecipeDetailLoaded(recipe: recipe)),
    );
  }
  
  Future<void> _onToggleFavoriteRecipe(
    ToggleFavoriteRecipe event,
    Emitter<RecipeDetailState> emit,
  ) async {
    // Make sure we have a recipe loaded before attempting to toggle favorite
    if (state is RecipeDetailLoaded) {
      final currentState = state as RecipeDetailLoaded;
      final recipe = currentState.recipe;
      
      // Emit loading state but keep the recipe visible
      emit(FavoriteToggleLoading(recipe: recipe));
      
      final result = await toggleFavorite(FavoriteParams(
        recipeId: event.recipeId,
        currentStatus: event.currentStatus,
      ));
      
      result.fold(
        (failure) => emit(FavoriteToggleError(
          recipe: recipe,
          failure: failure,
        )),
        (isFavorite) => emit(FavoriteToggleSuccess(
          recipe: recipe.copyWith(isFavorite: isFavorite),
          isFavorite: isFavorite,
        )),
      );
      
      // Update the main recipe state with the new favorite status
      if (state is FavoriteToggleSuccess) {
        final toggleState = state as FavoriteToggleSuccess;
        emit(RecipeDetailLoaded(recipe: toggleState.recipe));
      } else if (state is FavoriteToggleError) {
        // Revert to previous state if failed
        emit(currentState);
      }
    }
  }
  
  Future<void> _onRefreshRecipeDetail(
    RefreshRecipeDetail event,
    Emitter<RecipeDetailState> emit,
  ) async {
    // Keep the current recipe visible while refreshing
    RecipeDetail? currentRecipe;
    if (state is RecipeDetailLoaded) {
      currentRecipe = (state as RecipeDetailLoaded).recipe;
    }
    
    // If we have a current recipe, show a "refreshing" state that doesn't blank the screen
    if (currentRecipe != null) {
      // We could create a "RefreshingRecipeDetail" state here if needed
      // For now, just keep using the loaded state
    } else {
      emit(const RecipeDetailLoading());
    }
    
    final result = await getRecipeDetail(RecipeParams(recipeId: event.recipeId));
    
    result.fold(
      (failure) => emit(RecipeDetailError(failure: failure)),
      (recipe) => emit(RecipeDetailLoaded(recipe: recipe)),
    );
  }
} 