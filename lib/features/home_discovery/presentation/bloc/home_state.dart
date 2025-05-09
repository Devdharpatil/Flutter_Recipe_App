part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Recipe> trendingRecipes;
  final List<Recipe> weeklyRecipes;
  final List<String> categories;
  final Failure? trendingFailure;
  final Failure? categoriesFailure;
  final bool isRefreshing;

  const HomeLoaded({
    required this.trendingRecipes,
    required this.weeklyRecipes,
    required this.categories,
    this.trendingFailure,
    this.categoriesFailure,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    trendingRecipes,
    weeklyRecipes,
    categories,
    trendingFailure,
    categoriesFailure,
    isRefreshing,
  ];

  bool get hasTrendingRecipes => trendingRecipes.isNotEmpty;
  bool get hasWeeklyRecipes => weeklyRecipes.isNotEmpty;
  bool get hasCategories => categories.isNotEmpty;
  bool get hasAnyContent => hasTrendingRecipes || hasWeeklyRecipes || hasCategories;
  bool get hasTrendingError => trendingFailure != null;
  bool get hasCategoriesError => categoriesFailure != null;
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
} 