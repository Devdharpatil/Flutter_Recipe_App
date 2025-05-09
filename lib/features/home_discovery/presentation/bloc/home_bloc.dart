import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_trending_recipes_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTrendingRecipesUseCase getTrendingRecipesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  HomeBloc({
    required this.getTrendingRecipesUseCase,
    required this.getCategoriesUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeInitial) {
      emit(HomeLoading());
      await _fetchData(emit);
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(HomeLoaded(
        trendingRecipes: currentState.trendingRecipes,
        weeklyRecipes: currentState.weeklyRecipes,
        categories: currentState.categories,
        isRefreshing: true,
      ));
    } else {
      emit(HomeLoading());
    }
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    final trendingResult = await getTrendingRecipesUseCase(NoParams());
    final categoriesResult = await getCategoriesUseCase(NoParams());

    final trendingEither = trendingResult;
    final categoriesEither = categoriesResult;

    List<Recipe>? trending;
    List<String>? categories;
    Failure? trendingFailure;
    Failure? categoriesFailure;

    trendingEither.fold(
      (failure) => trendingFailure = failure,
      (recipes) => trending = recipes,
    );

    categoriesEither.fold(
      (failure) => categoriesFailure = failure,
      (cats) => categories = cats,
    );

    if (trendingFailure != null && categoriesFailure != null) {
      emit(HomeError(message: 'Failed to load home data'));
      return;
    }

    // Create weekly recipes based on trending recipes
    // In a real app, this would be a separate API call
    List<Recipe> weekly = [];
    if (trending != null && trending!.isNotEmpty) {
      // Mix up the trending recipes to create a different set for weekly recipes
      weekly = List.from(trending!);
      weekly.shuffle();
      
      // Make some modifications to make them appear different
      for (var i = 0; i < weekly.length; i++) {
        final recipe = weekly[i];
        // In a real app, you would fetch different recipes from a different endpoint
        // This is just a simulation to show different content
        if (recipe.healthScore != null) {
          recipe.healthScore = (recipe.healthScore! * 1.2).round().toDouble();
        }
      }
    }

    emit(HomeLoaded(
      trendingRecipes: trending ?? [],
      weeklyRecipes: weekly,
      categories: categories ?? [],
      trendingFailure: trendingFailure,
      categoriesFailure: categoriesFailure,
      isRefreshing: false,
    ));
  }
} 