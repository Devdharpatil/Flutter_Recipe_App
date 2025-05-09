import 'package:flutter/material.dart';

/// A reusable animated heart/favorite button with smooth pulse animation.
/// 
/// This component provides a consistent favorite/like interaction across the entire app.
/// Features include:
/// - Smooth scale animation when toggled
/// - Elegant transition between filled and outlined heart
/// - Configurable size and background appearance
/// - Haptic feedback (optional)
class AnimatedHeartButton extends StatefulWidget {
  /// Whether the heart is in favorite/liked state
  final bool isFavorite;
  
  /// Callback when the favorite state is toggled
  final VoidCallback onToggle;
  
  /// Width of the button container (default: 36)
  final double width;
  
  /// Height of the button container (default: 30)
  final double height;
  
  /// Size of the heart icon (default: 22)
  final double iconSize;
  
  /// Enable or disable the background container effect (default: true)
  final bool showBackground;
  
  /// Padding around the heart icon (default: EdgeInsets.symmetric(horizontal: 6, vertical: 4))
  final EdgeInsetsGeometry padding;
  
  /// Customize the color of the heart icon (default: Colors.red)
  final Color heartColor;
  
  /// Customize the background color when favorite (default: heartColor.withOpacity(0.1))
  final Color? favoriteBackgroundColor;
  
  /// Border radius for the container (default: 18)
  final double borderRadius;
  
  const AnimatedHeartButton({
    Key? key,
    required this.isFavorite,
    required this.onToggle,
    this.width = 36,
    this.height = 30,
    this.iconSize = 22,
    this.showBackground = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.heartColor = Colors.red,
    this.favoriteBackgroundColor,
    this.borderRadius = 18,
  }) : super(key: key);

  @override
  State<AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<AnimatedHeartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    // Multi-step bounce animation for heart
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 2.2), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 2.2, end: 0.6), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.4), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 0.8), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onToggle();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: widget.showBackground ? BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: widget.isFavorite 
                  ? widget.favoriteBackgroundColor ?? widget.heartColor.withOpacity(0.1) 
                  : Colors.transparent,
            ) : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                    reverseCurve: Curves.easeOutCubic,
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: widget.isFavorite
                ? Icon(
                    Icons.favorite,
                    key: const ValueKey<bool>(true),
                    size: widget.iconSize,
                    color: widget.heartColor,
                  )
                : ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          widget.heartColor.withOpacity(0.9),
                          widget.heartColor.withOpacity(0.9),
                        ],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      Icons.favorite_border,
                      key: const ValueKey<bool>(false),
                      size: widget.iconSize,
                      color: widget.heartColor,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
} 