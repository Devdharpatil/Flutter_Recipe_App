import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for getting a user's preferences
class GetUserPreferencesUseCase implements UseCase<UserPreferences, NoParams> {
  final UserProfileRepository repository;

  GetUserPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, UserPreferences>> call([NoParams params = const NoParams()]) {
    return repository.getUserPreferences();
  }
} 