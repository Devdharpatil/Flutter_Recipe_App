import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating a user's preferences
class UpdateUserPreferencesUseCase implements UseCase<UserPreferences, UpdateUserPreferencesParams> {
  final UserProfileRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, UserPreferences>> call(UpdateUserPreferencesParams params) {
    return repository.updateUserPreferences(
      dietaryPrefs: params.dietaryPrefs,
      cookingGoals: params.cookingGoals,
    );
  }
}

/// Parameters for updating user preferences
class UpdateUserPreferencesParams extends Equatable {
  final List<String> dietaryPrefs;
  final List<String> cookingGoals;

  const UpdateUserPreferencesParams({
    required this.dietaryPrefs,
    required this.cookingGoals,
  });

  @override
  List<Object?> get props => [dietaryPrefs, cookingGoals];
} 