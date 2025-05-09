import 'package:flutter/material.dart';

/// A shared error view widget that displays an error message with retry button
class ErrorView extends StatelessWidget {
  /// Error message to display
  final String message;
  
  /// Function to call when retry button is pressed
  final VoidCallback onRetry;
  
  /// Icon to display
  final IconData? icon;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: colorScheme.error.withOpacity(0.8),
            ),
            const SizedBox(height: 16),

            // Error message
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),

            // Retry button
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 