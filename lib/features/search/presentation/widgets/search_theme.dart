import 'package:flutter/material.dart';

class SearchThemeColors {
  // Primary
  static Color primaryLight(BuildContext context) => Theme.of(context).colorScheme.primary;
  static Color primaryContainerLight(BuildContext context) => Theme.of(context).colorScheme.primaryContainer;
  
  // Secondary
  static Color secondaryLight(BuildContext context) => Theme.of(context).colorScheme.secondary;
  static Color secondaryContainerLight(BuildContext context) => Theme.of(context).colorScheme.secondaryContainer;
  
  // Surface
  static Color surfaceLight(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color surfaceVariantLight(BuildContext context) => Theme.of(context).colorScheme.surfaceVariant;
  
  // Background
  static Color backgroundLight(BuildContext context) => Theme.of(context).colorScheme.background;
  
  // Text
  static Color textPrimaryLight(BuildContext context) => Theme.of(context).colorScheme.onBackground;
  static Color textSecondaryLight(BuildContext context) => Theme.of(context).colorScheme.onBackground.withOpacity(0.7);
  static Color textTertiaryLight(BuildContext context) => Theme.of(context).colorScheme.onBackground.withOpacity(0.5);
  
  // Gradients
  static List<Color> primaryGradient(BuildContext context) => [
    Theme.of(context).colorScheme.primaryContainer,
    Theme.of(context).colorScheme.primary.withOpacity(0.7),
  ];
  
  static List<Color> secondaryGradient(BuildContext context) => [
    Theme.of(context).colorScheme.secondaryContainer,
    Theme.of(context).colorScheme.secondary.withOpacity(0.7),
  ];
  
  static List<Color> neutralGradient(BuildContext context) => [
    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
    Theme.of(context).colorScheme.surfaceVariant,
  ];
}

class SearchThemeRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
  static const double circle = 100.0;
}

class SearchThemeShadows {
  static List<BoxShadow> small(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
      blurRadius: 4,
      spreadRadius: 1,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> medium(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
      blurRadius: 8,
      spreadRadius: 1,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> large(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
      blurRadius: 12,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];
}

class SearchThemePadding {
  static const EdgeInsets small = EdgeInsets.all(8.0);
  static const EdgeInsets medium = EdgeInsets.all(16.0);
  static const EdgeInsets large = EdgeInsets.all(24.0);
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets vertical = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets content = EdgeInsets.fromLTRB(16, 12, 16, 12);
}

class SearchThemeAnimations {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration long = Duration(milliseconds: 600);
  
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
} 