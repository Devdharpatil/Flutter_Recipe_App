import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../home_discovery/domain/entities/recipe.dart';
import '../../domain/entities/filter_options.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class AutocompleteSuggestionsLoading extends SearchState {
  final String query;
  final List<String> recentSearches;
  
  const AutocompleteSuggestionsLoading({
    required this.query,
    this.recentSearches = const [],
  });
  
  @override
  List<Object> get props => [query, recentSearches];
}

class AutocompleteSuggestionsLoaded extends SearchState {
  final String query;
  final List<String> suggestions;
  final List<String> recentSearches;
  
  const AutocompleteSuggestionsLoaded({
    required this.query,
    required this.suggestions,
    this.recentSearches = const [],
  });
  
  @override
  List<Object> get props => [query, suggestions, recentSearches];
}

class AutocompleteSuggestionsError extends SearchState {
  final String query;
  final Failure failure;
  final List<String> recentSearches;
  
  const AutocompleteSuggestionsError({
    required this.query,
    required this.failure,
    this.recentSearches = const [],
  });
  
  @override
  List<Object> get props => [query, failure, recentSearches];
}

class RecentSearchesLoaded extends SearchState {
  final List<String> recentSearches;
  
  const RecentSearchesLoaded({required this.recentSearches});
  
  @override
  List<Object> get props => [recentSearches];
}

class SearchResultsLoading extends SearchState {
  final String query;
  final FilterOptions? filterOptions;
  
  const SearchResultsLoading({
    required this.query,
    this.filterOptions,
  });
  
  @override
  List<Object?> get props => [query, filterOptions];
}

class SearchResultsLoaded extends SearchState {
  final String query;
  final List<Recipe> recipes;
  final FilterOptions? filterOptions;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final Failure? loadMoreFailure;
  final int totalResults;
  
  const SearchResultsLoaded({
    required this.query,
    required this.recipes,
    this.filterOptions,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
    this.loadMoreFailure,
    this.totalResults = 0,
  });
  
  @override
  List<Object?> get props => [
    query,
    recipes,
    filterOptions,
    hasReachedMax,
    isFetchingMore,
    loadMoreFailure,
    totalResults,
  ];
  
  SearchResultsLoaded copyWith({
    String? query,
    List<Recipe>? recipes,
    FilterOptions? filterOptions,
    bool? hasReachedMax,
    bool? isFetchingMore,
    Failure? loadMoreFailure,
    int? totalResults,
  }) {
    return SearchResultsLoaded(
      query: query ?? this.query,
      recipes: recipes ?? this.recipes,
      filterOptions: filterOptions ?? this.filterOptions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      loadMoreFailure: loadMoreFailure,
      totalResults: totalResults ?? this.totalResults,
    );
  }
}

class SearchResultsEmpty extends SearchState {
  final String query;
  final FilterOptions? filterOptions;
  
  const SearchResultsEmpty({
    required this.query,
    this.filterOptions,
  });
  
  @override
  List<Object?> get props => [query, filterOptions];
}

class SearchResultsError extends SearchState {
  final String query;
  final Failure failure;
  final FilterOptions? filterOptions;
  
  const SearchResultsError({
    required this.query,
    required this.failure,
    this.filterOptions,
  });
  
  @override
  List<Object?> get props => [query, failure, filterOptions];
} 