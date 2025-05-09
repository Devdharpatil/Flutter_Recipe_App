import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/search_repository.dart';

class GetAutocompleteSuggestionsUseCase {
  final SearchRepository repository;

  GetAutocompleteSuggestionsUseCase(this.repository);
  
  Future<Either<Failure, List<String>>> call(String query) {
    if (query.length < 2) {
      return Future.value(const Right([]));
    }
    return repository.getAutocompleteSuggestions(query);
  }
} 