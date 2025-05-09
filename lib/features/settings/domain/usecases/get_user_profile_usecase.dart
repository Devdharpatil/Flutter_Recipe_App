import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for getting the current user's profile
class GetUserProfileUseCase implements UseCase<UserProfile?, NoParams> {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile?>> call([NoParams params = const NoParams()]) {
    return repository.getUserProfile();
  }
} 