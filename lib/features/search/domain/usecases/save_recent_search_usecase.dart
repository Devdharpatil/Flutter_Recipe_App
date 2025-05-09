import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/search_repository.dart';

class SaveRecentSearchUseCase {
  final SearchRepository repository;

  SaveRecentSearchUseCase(this.repository);
  
  Future<Either<Failure, bool>> call(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const Right(false));
    }
    return repository.saveRecentSearch(query.trim());
  }
} 