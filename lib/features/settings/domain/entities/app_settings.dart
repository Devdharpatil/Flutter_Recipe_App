import 'package:equatable/equatable.dart';

/// Entity representing app settings
class AppSettings extends Equatable {
  final String themePreference;

  const AppSettings({
    required this.themePreference,
  });

  @override
  List<Object?> get props => [themePreference];
} 