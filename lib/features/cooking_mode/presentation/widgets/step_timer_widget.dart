import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StepTimerWidget extends StatelessWidget {
  /// Duration in seconds for the timer
  final int? duration;
  
  /// Whether the timer is currently active
  final bool isActive;
  
  /// Remaining seconds if the timer is already running
  final int? remainingSeconds;
  
  /// Callback for starting the timer
  final VoidCallback? onStart;
  
  /// Callback for pausing the timer
  final VoidCallback? onPause;
  
  /// Callback for resuming the timer
  final VoidCallback? onResume;
  
  /// Callback for resetting the timer
  final VoidCallback? onReset;

  const StepTimerWidget({
    super.key,
    this.duration,
    this.isActive = false,
    this.remainingSeconds,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine which seconds to display
    final secondsToDisplay = remainingSeconds ?? duration ?? 0;
    final originalDuration = duration ?? secondsToDisplay;

    // Calculate progress (from 0.0 to 1.0)
    final double progress = originalDuration > 0 
        ? secondsToDisplay / originalDuration
        : 0.0;
    
    // Has timer been started
    final bool isInitialized = remainingSeconds != null;
    
    // Choose colors based on timer state
    final Color primaryColor = isActive 
        ? AppColors.warning 
        : theme.colorScheme.primary;
    
    final Color backgroundColor = isActive
        ? theme.colorScheme.errorContainer.withOpacity(0.15)
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isActive
              ? AppColors.warning.withOpacity(0.7)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Timer Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.timer : Icons.timer_outlined,
                color: primaryColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                isActive ? 'Timer Running' : 'Timer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Timer Display
          Stack(
            alignment: Alignment.center,
            children: [
              // Timer Progress Indicator
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: isInitialized ? progress : 1.0,
                  strokeWidth: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: primaryColor,
                ),
              ),
              
              // Time Text
              Column(
                children: [
          Text(
            _formatTime(secondsToDisplay),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  if (isInitialized && !isActive)
                    Text(
                      'paused',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
            ),
          ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Timer Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isInitialized)
                _buildTimerButton(
                  context,
                  Icons.play_arrow_rounded,
                  'Start',
                  onStart,
                  theme.colorScheme.primary,
                )
              else if (isActive)
                _buildTimerButton(
                  context,
                  Icons.pause_rounded,
                  'Pause',
                  onPause,
                  AppColors.warning,
                  isOutlined: false,
                )
              else
                _buildTimerButton(
                  context,
                  Icons.play_arrow_rounded,
                  'Resume',
                  onResume,
                  theme.colorScheme.primary,
                ),
              
              if (isInitialized) ...[
                const SizedBox(width: 16),
                _buildTimerButton(
                  context,
                  Icons.refresh_rounded,
                  'Reset',
                  onReset,
                  theme.colorScheme.error,
                  isOutlined: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimerButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onPressed,
    Color color, {
    bool isOutlined = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: isOutlined ? color : Colors.white,
        backgroundColor: isOutlined ? Colors.transparent : color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: isOutlined ? BorderSide(color: color, width: 2) : null,
        elevation: isOutlined ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
  
  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
} 