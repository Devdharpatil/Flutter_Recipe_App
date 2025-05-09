import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_recipes_by_category_usecase.dart';
import '../../../../core/error/failures.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetRecipesByCategoryUseCase getRecipesByCategoryUseCase;

  CategoryBloc({
    required this.getRecipesByCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategoryRecipes>(_onLoadCategoryRecipes);
    on<LoadMoreCategoryRecipes>(_onLoadMoreCategoryRecipes);
  }

  Future<void> _onLoadCategoryRecipes(
    LoadCategoryRecipes event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    final result = await getRecipesByCategoryUseCase(CategoryParams(
      category: event.category,
      offset: 0,
      limit: 20,
    ));

    result.fold(
      (failure) => emit(CategoryError(message: _mapFailureToMessage(failure))),
      (recipes) => emit(CategoryLoaded(
        category: event.category,
        recipes: recipes,
        hasReachedMax: recipes.length < 20,
      )),
    );
  }

  Future<void> _onLoadMoreCategoryRecipes(
    LoadMoreCategoryRecipes event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoryLoaded && !currentState.hasReachedMax) {
      final result = await getRecipesByCategoryUseCase(CategoryParams(
        category: currentState.category,
        offset: currentState.recipes.length,
        limit: 20,
      ));

      result.fold(
        (failure) => emit(currentState.copyWith(
          loadMoreError: _mapFailureToMessage(failure),
        )),
        (recipes) => emit(currentState.copyWith(
          recipes: List.of(currentState.recipes)..addAll(recipes),
          hasReachedMax: recipes.length < 20,
          loadMoreError: null,
        )),
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
} 