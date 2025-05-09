import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<UserProfile, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(SignUpParams params) {
    return repository.signUp(
      displayName: params.displayName,
      email: params.email,
      password: params.password,
      receiveUpdates: params.receiveUpdates,
    );
  }
}

class SignUpParams extends Equatable {
  final String displayName;
  final String email;
  final String password;
  final bool receiveUpdates;

  const SignUpParams({
    required this.displayName,
    required this.email,
    required this.password,
    this.receiveUpdates = false,
  });

  @override
  List<Object?> get props => [displayName, email, password, receiveUpdates];
} 