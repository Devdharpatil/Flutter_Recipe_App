import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for getting the current app settings
class GetAppSettingsUseCase implements UseCase<AppSettings, NoParams> {
  final UserProfileRepository repository;

  GetAppSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call([NoParams params = const NoParams()]) {
    return repository.getAppSettings();
  }
} 