import 'package:flutter/material.dart';

/// A standard loading indicator to be used across the app
class LoadingIndicator extends StatelessWidget {
  /// Size of the indicator
  final double size;
  
  /// Color of the indicator (uses primary color by default)
  final Color? color;
  
  /// Stroke width of the indicator
  final double strokeWidth;
  
  /// Whether to show a label below the indicator
  final bool showLabel;
  
  /// Text to display if [showLabel] is true
  final String label;

  const LoadingIndicator({
    super.key,
    this.size = 48.0,
    this.color,
    this.strokeWidth = 4.0,
    this.showLabel = false,
    this.label = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? theme.colorScheme.primary,
            ),
            strokeWidth: strokeWidth,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 16),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
} 