import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating app settings
class UpdateAppSettingsUseCase implements UseCase<AppSettings, UpdateAppSettingsParams> {
  final UserProfileRepository repository;

  UpdateAppSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call(UpdateAppSettingsParams params) {
    return repository.updateAppSettings(
      themePreference: params.themePreference,
    );
  }
}

/// Parameters for updating app settings
class UpdateAppSettingsParams extends Equatable {
  final String themePreference;

  const UpdateAppSettingsParams({
    required this.themePreference,
  });

  @override
  List<Object?> get props => [themePreference];
} 