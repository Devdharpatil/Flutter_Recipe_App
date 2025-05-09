part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String displayName;
  final String email;
  final String password;
  final bool receiveUpdates;

  const SignUpRequested({
    required this.displayName,
    required this.email,
    required this.password,
    this.receiveUpdates = false,
  });

  @override
  List<Object> get props => [displayName, email, password, receiveUpdates];
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

// Event to reset error state
class AuthResetError extends AuthEvent {
  const AuthResetError();
} 