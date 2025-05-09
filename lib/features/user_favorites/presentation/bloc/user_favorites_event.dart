import 'package:equatable/equatable.dart';

abstract class UserFavoritesEvent extends Equatable {
  const UserFavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends UserFavoritesEvent {
  const LoadFavorites();
}

class ToggleFavorite extends UserFavoritesEvent {
  final int recipeId;
  final bool currentStatus;

  const ToggleFavorite({
    required this.recipeId,
    required this.currentStatus,
  });

  @override
  List<Object?> get props => [recipeId, currentStatus];
} 