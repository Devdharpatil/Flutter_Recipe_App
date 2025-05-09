import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A beautifully designed, animated search bar for the home screen.
/// Features a clean design with subtle animations and optional filter button.
class EnhancedSearchBar extends StatefulWidget {
  /// Placeholder text for the search bar
  final String hintText;
  
  /// Callback when the search bar is tapped
  final VoidCallback onTap;
  
  /// Callback when the filter button is tapped
  final VoidCallback? onFilterTap;
  
  /// Whether to show the filter button
  final bool showFilterButton;
  
  /// Optional custom width
  final double? width;

  const EnhancedSearchBar({
    Key? key,
    this.hintText = 'Search any recipes',
    required this.onTap,
    this.onFilterTap,
    this.showFilterButton = true,
    this.width,
  }) : super(key: key);

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.03, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    ));
    
    // Start the subtle pulse animation
    _animationController.repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _isPressed = true;
    });
    
    // Quick animation sequence for press effect
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap();
      }
    });
  }
  
  void _handleFilterTap() {
    HapticFeedback.lightImpact();
    if (widget.onFilterTap != null) {
      widget.onFilterTap!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed 
                ? _scaleAnimation.value
                : _isHovered ? _pulseAnimation.value : 1.0,
              child: Transform.rotate(
                angle: _isPressed ? _rotateAnimation.value : 0.0,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _isHovered || _isPressed
                      ? colorScheme.primary.withOpacity(0.15)
                      : colorScheme.onSurface.withOpacity(0.06),
                  blurRadius: _isHovered || _isPressed ? 12 : 8,
                  offset: _isHovered || _isPressed
                      ? const Offset(0, 4)
                      : const Offset(0, 2),
                  spreadRadius: _isHovered || _isPressed ? 1 : 0,
                ),
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: _isHovered || _isPressed
                    ? colorScheme.primary.withOpacity(0.4) 
                    : colorScheme.outline.withOpacity(0.2),
                width: _isHovered || _isPressed ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                // Search icon
                const SizedBox(width: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: _isPressed ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 0.5, // Rotate up to 30 degrees when pressed
                      child: Icon(
                        Icons.search_rounded,
                        color: Color.lerp(
                          _isHovered ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          colorScheme.primary,
                          value, // Interpolate color based on animation value
                        ),
                        size: 24 + (value * 4), // Grow slightly when pressed
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                
                // Hint text with animation
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: _isPressed ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Text(
                        widget.hintText,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Color.lerp(
                            colorScheme.onSurfaceVariant,
                            colorScheme.primary.withOpacity(0.7),
                            value, // Interpolate color based on animation value
                          ),
                          fontWeight: FontWeight.lerp(
                            FontWeight.normal,
                            FontWeight.w500,
                            value, // Interpolate weight based on animation value
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Filter button (optional) with animation
                if (widget.showFilterButton) 
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: _isPressed ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return IconButton(
                        icon: Transform.rotate(
                          angle: value * 0.2, // Slight rotation on press
                          child: Icon(
                            Icons.tune_rounded,
                            color: widget.onFilterTap != null
                                ? Color.lerp(
                                    _isHovered ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                    colorScheme.primary,
                                    value, // Interpolate color based on animation value
                                  )
                                : colorScheme.onSurfaceVariant.withOpacity(0.5),
                            size: 24 + (value * 2), // Slight grow on press
                          ),
                        ),
                        onPressed: widget.onFilterTap != null ? _handleFilterTap : null,
                      );
                    },
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 