import 'package:equatable/equatable.dart';
import '../../domain/entities/filter_options.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class LoadAutocompleteSuggestions extends SearchEvent {
  final String query;

  const LoadAutocompleteSuggestions(this.query);

  @override
  List<Object> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  final String query;
  final FilterOptions? filterOptions;

  const SearchSubmitted({
    required this.query,
    this.filterOptions,
  });

  @override
  List<Object?> get props => [query, filterOptions];
}

class LoadMoreResults extends SearchEvent {
  const LoadMoreResults();
}

class LoadRecentSearches extends SearchEvent {
  const LoadRecentSearches();
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class UpdateFilterOptions extends SearchEvent {
  final FilterOptions filterOptions;

  const UpdateFilterOptions(this.filterOptions);

  @override
  List<Object> get props => [filterOptions];
}

class SaveRecentSearch extends SearchEvent {
  final String query;

  const SaveRecentSearch(this.query);

  @override
  List<Object> get props => [query];
} 