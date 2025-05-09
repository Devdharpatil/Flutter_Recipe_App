import 'package:equatable/equatable.dart';

abstract class RecipeDetailEvent extends Equatable {
  const RecipeDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchRecipeDetail extends RecipeDetailEvent {
  final int recipeId;

  const FetchRecipeDetail({required this.recipeId});

  @override
  List<Object> get props => [recipeId];
}

class ToggleFavoriteRecipe extends RecipeDetailEvent {
  final int recipeId;
  final bool currentStatus;

  const ToggleFavoriteRecipe({
    required this.recipeId,
    required this.currentStatus,
  });

  @override
  List<Object> get props => [recipeId, currentStatus];
}

class RefreshRecipeDetail extends RecipeDetailEvent {
  final int recipeId;

  const RefreshRecipeDetail({required this.recipeId});

  @override
  List<Object> get props => [recipeId];
} 