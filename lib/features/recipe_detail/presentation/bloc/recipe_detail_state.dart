import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/recipe_detail.dart';

abstract class RecipeDetailState extends Equatable {
  const RecipeDetailState();

  @override
  List<Object?> get props => [];
}

class RecipeDetailInitial extends RecipeDetailState {
  const RecipeDetailInitial();
}

class RecipeDetailLoading extends RecipeDetailState {
  const RecipeDetailLoading();
}

class RecipeDetailLoaded extends RecipeDetailState {
  final RecipeDetail recipe;

  const RecipeDetailLoaded({required this.recipe});

  @override
  List<Object> get props => [recipe];
  
  // Helper method to create a new state with updated favorite status
  RecipeDetailLoaded copyWith({bool? isFavorite}) {
    if (isFavorite == null) return this;
    
    final updatedRecipe = recipe.copyWith(
      isFavorite: isFavorite,
    );
    
    return RecipeDetailLoaded(recipe: updatedRecipe);
  }
}

class RecipeDetailError extends RecipeDetailState {
  final Failure failure;

  const RecipeDetailError({required this.failure});

  @override
  List<Object> get props => [failure];
}

class FavoriteToggleLoading extends RecipeDetailState {
  final RecipeDetail recipe;
  
  const FavoriteToggleLoading({required this.recipe});
  
  @override
  List<Object> get props => [recipe];
}

class FavoriteToggleSuccess extends RecipeDetailState {
  final RecipeDetail recipe;
  final bool isFavorite;
  
  const FavoriteToggleSuccess({
    required this.recipe, 
    required this.isFavorite
  });
  
  @override
  List<Object> get props => [recipe, isFavorite];
}

class FavoriteToggleError extends RecipeDetailState {
  final RecipeDetail recipe;
  final Failure failure;
  
  const FavoriteToggleError({
    required this.recipe, 
    required this.failure
  });
  
  @override
  List<Object> get props => [recipe, failure];
} 