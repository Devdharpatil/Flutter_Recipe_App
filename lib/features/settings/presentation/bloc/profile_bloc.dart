import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

// Event classes
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileFetched extends ProfileEvent {
  const ProfileFetched();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String displayName;
  final String? avatarUrl;

  const ProfileUpdateRequested({
    required this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [displayName, avatarUrl];
}

// State classes
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  const ProfileLoaded({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileUpdating extends ProfileState {
  final UserProfile userProfile;

  const ProfileUpdating({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile userProfile;

  const ProfileUpdated({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileError extends ProfileState {
  final String message;
  final UserProfile? userProfile;

  const ProfileError({required this.message, this.userProfile});

  @override
  List<Object?> get props => [message, userProfile];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(const ProfileInitial()) {
    on<ProfileFetched>(_onProfileFetched);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileFetched(
    ProfileFetched event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getUserProfile();
    
    emit(result.fold(
      (failure) => ProfileError(message: _mapFailureToMessage(failure)),
      (profile) => profile != null 
          ? ProfileLoaded(userProfile: profile)
          : const ProfileError(message: 'Profile not found'),
    ));
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // First emit updating state while keeping the current profile data
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      emit(const ProfileError(message: 'Cannot update: profile not loaded'));
      return;
    }

    emit(ProfileUpdating(userProfile: currentState.userProfile));

    // Perform the update
    final result = await updateUserProfile(
      UpdateUserProfileParams(
        displayName: event.displayName,
        avatarUrl: event.avatarUrl,
      ),
    );
    
    // Handle result
    emit(result.fold(
      (failure) => ProfileError(
        message: _mapFailureToMessage(failure),
        // Return the existing profile data to avoid data loss
        userProfile: currentState.userProfile,
      ), 
      (updatedProfile) => ProfileUpdated(userProfile: updatedProfile),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
} 