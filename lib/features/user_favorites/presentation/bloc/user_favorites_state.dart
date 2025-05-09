import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

abstract class UserFavoritesState extends Equatable {
  const UserFavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends UserFavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends UserFavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends UserFavoritesState {
  final Set<int> favoriteRecipeIds;

  const FavoritesLoaded({required this.favoriteRecipeIds});

  @override
  List<Object?> get props => [favoriteRecipeIds];
}

class FavoritesError extends UserFavoritesState {
  final Failure failure;

  const FavoritesError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// Optional transient state for snackbar messages
class FavoritesActionInProgress extends UserFavoritesState {
  const FavoritesActionInProgress();
}

class FavoritesActionSuccess extends UserFavoritesState {
  final String message;

  const FavoritesActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class FavoritesActionFailure extends UserFavoritesState {
  final String message;

  const FavoritesActionFailure({required this.message});

  @override
  List<Object?> get props => [message];
} 