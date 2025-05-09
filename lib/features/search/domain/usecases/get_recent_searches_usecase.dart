import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/search_repository.dart';

class GetRecentSearchesUseCase {
  final SearchRepository repository;

  GetRecentSearchesUseCase(this.repository);
  
  Future<Either<Failure, List<String>>> call() {
    return repository.getRecentSearches();
  }
} 