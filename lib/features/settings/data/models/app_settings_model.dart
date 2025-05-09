import '../../domain/entities/app_settings.dart';

/// Model class for app settings
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.themePreference,
  });

  /// Create a model from a JSON map
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      themePreference: json['theme_preference'] ?? 'system',
    );
  }

  /// Convert the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'theme_preference': themePreference,
    };
  }
} 