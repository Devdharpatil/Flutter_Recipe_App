part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategoryRecipes extends CategoryEvent {
  final String category;

  const LoadCategoryRecipes({required this.category});

  @override
  List<Object> get props => [category];
}

class LoadMoreCategoryRecipes extends CategoryEvent {
  const LoadMoreCategoryRecipes();
} 