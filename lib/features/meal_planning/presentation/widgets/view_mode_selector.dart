import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bloc/meal_plan_state.dart';

class ViewModeSelector extends StatefulWidget {
  final ViewMode selectedMode;
  final void Function(ViewMode) onViewModeChanged;

  const ViewModeSelector({
    super.key,
    required this.selectedMode,
    required this.onViewModeChanged,
  });

  @override
  State<ViewModeSelector> createState() => _ViewModeSelectorState();
}

class _ViewModeSelectorState extends State<ViewModeSelector> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animation when widget is built
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 56, // Increased height for better touch targets
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceVariant.withOpacity(0.4),
              colorScheme.surfaceVariant.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: ViewMode.values.map((mode) {
              final isSelected = mode == widget.selectedMode;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onViewModeChanged(mode);
                    
                    // Animate the selection change
                    _animationController.reset();
                    _animationController.forward();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withBlue(colorScheme.primary.blue + 10),
                        ],
                      ) : null,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: -1,
                        ),
                      ] : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle wave pattern for selected tab
                        if (isSelected)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: ShaderMask(
                                blendMode: BlendMode.srcATop,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ).createShader(bounds);
                                },
                                child: CustomPaint(
                                  painter: WavePatternPainter(
                                    color: Colors.white.withOpacity(0.07),
                                  ),
                                  size: const Size(double.infinity, double.infinity),
                                ),
                              ),
                            ),
                          ),
                        
                        // Content
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with highlight effect
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.15) 
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getViewModeIcon(mode),
                                  style: TextStyle(
                                    fontSize: 14,
                                    // Add slight glow effect for selected icons
                                    shadows: isSelected ? [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 8,
                                      )
                                    ] : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Text label with enhanced typography
                            Text(
                              mode.label,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.3,
                                // Add subtle shadow for selected text
                                shadows: isSelected ? [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ] : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  String _getViewModeIcon(ViewMode mode) {
    switch (mode) {
      case ViewMode.daily:
        return '📆';
      case ViewMode.weekly:
        return '📅';
      case ViewMode.monthly:
        return '🗓️';
    }
  }
}

// Custom painter that creates a subtle wave pattern background
class WavePatternPainter extends CustomPainter {
  final Color color;
  
  WavePatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    
    final double waveHeight = 6;
    final double waveSpacing = 12;
    final double verticalOffset = size.height / 4;
    
    for (int i = 0; i < size.height / waveSpacing; i++) {
      final path = Path();
      final yOffset = i * waveSpacing + verticalOffset;
      
      path.moveTo(0, yOffset);
      
      for (double x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10, yOffset - waveHeight,
          x + 20, yOffset,
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 