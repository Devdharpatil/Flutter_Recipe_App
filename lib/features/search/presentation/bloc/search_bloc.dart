import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/search_recipes_usecase.dart';
import '../../domain/usecases/get_autocomplete_suggestions_usecase.dart';
import '../../domain/usecases/get_recent_searches_usecase.dart';
import '../../domain/usecases/save_recent_search_usecase.dart';
import './search_event.dart';
import './search_state.dart';

// Debounce duration for search typing
const _duration = Duration(milliseconds: 300);

// Throttle duration for pagination
const _throttleDuration = Duration(milliseconds: 500);

// Results per page
const _resultsPerPage = 20;

EventTransformer<Event> debounce<Event>() {
  return (events, mapper) {
    return events
        .debounceTime(_duration)
        .switchMap(mapper);
  };
}

EventTransformer<Event> throttle<Event>() {
  return (events, mapper) {
    return events
        .throttleTime(_throttleDuration)
        .switchMap(mapper);
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRecipesUseCase searchRecipesUseCase;
  final GetAutocompleteSuggestionsUseCase getAutocompleteSuggestionsUseCase;
  final GetRecentSearchesUseCase getRecentSearchesUseCase;
  final SaveRecentSearchUseCase saveRecentSearchUseCase;

  SearchBloc({
    required this.searchRecipesUseCase,
    required this.getAutocompleteSuggestionsUseCase,
    required this.getRecentSearchesUseCase,
    required this.saveRecentSearchUseCase,
  }) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged, transformer: debounce());
    on<LoadAutocompleteSuggestions>(_onLoadAutocompleteSuggestions);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<LoadMoreResults>(_onLoadMoreResults, transformer: throttle());
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<ClearSearch>(_onClearSearch);
    on<UpdateFilterOptions>(_onUpdateFilterOptions);
    on<SaveRecentSearch>(_onSaveRecentSearch);
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    final query = event.query.trim();
    
    if (query.isEmpty) {
      add(const LoadRecentSearches());
      return;
    }
    
    // Load autocomplete suggestions when query length >= 2
    if (query.length >= 2) {
      add(LoadAutocompleteSuggestions(query));
    }
  }

  Future<void> _onLoadAutocompleteSuggestions(
    LoadAutocompleteSuggestions event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    
    if (query.length < 2) return;
    
    // Get recent searches to preserve them in state
    List<String> recentSearches = [];
    final recentSearchesResult = await getRecentSearchesUseCase();
    recentSearchesResult.fold(
      (failure) => {},
      (searches) => recentSearches = searches,
    );
    
    emit(AutocompleteSuggestionsLoading(
      query: query,
      recentSearches: recentSearches,
    ));
    
    final suggestionsResult = await getAutocompleteSuggestionsUseCase(query);
    
    suggestionsResult.fold(
      (failure) => emit(AutocompleteSuggestionsError(
        query: query,
        failure: failure,
        recentSearches: recentSearches,
      )),
      (suggestions) => emit(AutocompleteSuggestionsLoaded(
        query: query,
        suggestions: suggestions,
        recentSearches: recentSearches,
      )),
    );
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    
    if (query.isEmpty) return;
    
    // Save search query to recent searches
    add(SaveRecentSearch(query));
    
    emit(SearchResultsLoading(
      query: query,
      filterOptions: event.filterOptions,
    ));
    
    final searchResult = await searchRecipesUseCase(
      query: query,
      filterOptions: event.filterOptions,
      offset: 0,
      limit: _resultsPerPage,
    );
    
    searchResult.fold(
      (failure) => emit(SearchResultsError(
        query: query,
        failure: failure,
        filterOptions: event.filterOptions,
      )),
      (recipes) {
        if (recipes.isEmpty) {
          emit(SearchResultsEmpty(
            query: query,
            filterOptions: event.filterOptions,
          ));
        } else {
          emit(SearchResultsLoaded(
            query: query,
            recipes: recipes,
            filterOptions: event.filterOptions,
            hasReachedMax: recipes.length < _resultsPerPage,
            totalResults: recipes.length,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is SearchResultsLoaded) {
      if (currentState.hasReachedMax || currentState.isFetchingMore) return;
      
      emit(currentState.copyWith(isFetchingMore: true));
      
      final moreRecipesResult = await searchRecipesUseCase(
        query: currentState.query,
        filterOptions: currentState.filterOptions,
        offset: currentState.recipes.length,
        limit: _resultsPerPage,
      );
      
      moreRecipesResult.fold(
        (failure) => emit(currentState.copyWith(
          isFetchingMore: false,
          loadMoreFailure: failure,
        )),
        (newRecipes) {
          final hasReachedMax = newRecipes.isEmpty || newRecipes.length < _resultsPerPage;
          
          emit(currentState.copyWith(
            recipes: [...currentState.recipes, ...newRecipes],
            isFetchingMore: false,
            hasReachedMax: hasReachedMax,
            totalResults: currentState.totalResults + newRecipes.length,
          ));
        },
      );
    }
  }

  Future<void> _onLoadRecentSearches(
    LoadRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    final recentSearchesResult = await getRecentSearchesUseCase();
    
    recentSearchesResult.fold(
      (failure) => emit(const RecentSearchesLoaded(recentSearches: [])),
      (searches) => emit(RecentSearchesLoaded(recentSearches: searches)),
    );
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    add(const LoadRecentSearches());
  }

  void _onUpdateFilterOptions(
    UpdateFilterOptions event,
    Emitter<SearchState> emit,
  ) {
    final currentState = state;
    
    if (currentState is SearchResultsLoaded) {
      add(SearchSubmitted(
        query: currentState.query,
        filterOptions: event.filterOptions,
      ));
    } else if (currentState is SearchResultsEmpty) {
      add(SearchSubmitted(
        query: currentState.query,
        filterOptions: event.filterOptions,
      ));
    } else if (currentState is SearchResultsError) {
      add(SearchSubmitted(
        query: currentState.query,
        filterOptions: event.filterOptions,
      ));
    }
  }

  Future<void> _onSaveRecentSearch(
    SaveRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;
    
    await saveRecentSearchUseCase(query);
  }
} 