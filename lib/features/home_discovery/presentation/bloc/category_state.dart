part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final String category;
  final List<Recipe> recipes;
  final bool hasReachedMax;
  final String? loadMoreError;

  const CategoryLoaded({
    required this.category,
    required this.recipes,
    this.hasReachedMax = false,
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [
    category,
    recipes,
    hasReachedMax,
    loadMoreError,
  ];

  CategoryLoaded copyWith({
    String? category,
    List<Recipe>? recipes,
    bool? hasReachedMax,
    String? loadMoreError,
  }) {
    return CategoryLoaded(
      category: category ?? this.category,
      recipes: recipes ?? this.recipes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      loadMoreError: loadMoreError,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object> get props => [message];
} 