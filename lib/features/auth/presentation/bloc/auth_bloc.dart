import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../../../core/error/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<AuthResetError>(_onAuthResetError);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
        ),
      );
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (_) => emit(AuthSuccess()),
      );
    } catch (e) {
      emit(AuthFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await signUpUseCase(
        SignUpParams(
          displayName: event.displayName,
          email: event.email,
          password: event.password,
          receiveUpdates: event.receiveUpdates,
        ),
      );
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (_) => emit(AuthSuccess()),
      );
    } catch (e) {
      emit(AuthFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await resetPasswordUseCase(
        ResetPasswordParams(
          email: event.email,
        ),
      );
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (_) => emit(const PasswordResetSuccess()),
      );
    } catch (e) {
      emit(AuthFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  void _onAuthResetError(
    AuthResetError event,
    Emitter<AuthState> emit,
  ) {
    // Reset to initial state to clear any error message
    emit(AuthInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your internet connection and try again.';
      case InvalidCredentialsFailure:
        return 'Invalid email or password. Please double-check your credentials and try again.';
      case EmailInUseFailure:
        return 'This email is already registered. Please try signing in or use a different email address.';
      case WeakPasswordFailure:
        return failure.message;
      case UserNotFoundFailure:
        return 'No account found with this email address. Please check your email or sign up for a new account.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }
} 