import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating a user's profile
class UpdateUserProfileUseCase implements UseCase<UserProfile, UpdateUserProfileParams> {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateUserProfileParams params) {
    return repository.updateUserProfile(
      displayName: params.displayName,
      avatarUrl: params.avatarUrl,
    );
  }
}

/// Parameters for updating user profile
class UpdateUserProfileParams extends Equatable {
  final String displayName;
  final String? avatarUrl;

  const UpdateUserProfileParams({
    required this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [displayName, avatarUrl];
} 