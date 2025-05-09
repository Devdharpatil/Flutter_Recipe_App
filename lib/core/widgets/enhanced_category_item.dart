import 'package:flutter/material.dart';

/// A beautifully designed category item widget for the home screen.
/// Features a clean design with icon, title, and optional background color.
class EnhancedCategoryItem extends StatefulWidget {
  /// The category name
  final String title;
  
  /// The icon to display
  final IconData icon;
  
  /// Callback when the category is tapped
  final VoidCallback onTap;
  
  /// Optional custom background color
  final Color? backgroundColor;
  
  /// Optional custom foreground/icon color
  final Color? foregroundColor;
  
  /// Optional custom size
  final double size;

  const EnhancedCategoryItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 90,
  }) : super(key: key);

  @override
  State<EnhancedCategoryItem> createState() => _EnhancedCategoryItemState();
}

class _EnhancedCategoryItemState extends State<EnhancedCategoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _onHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
  
  void _onPressedChange(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
    
    if (isPressed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Use provided colors or defaults from theme
    final bgColor = widget.backgroundColor ?? colorScheme.primary.withOpacity(0.15);
    final fgColor = widget.foregroundColor ?? colorScheme.primary;
    
    // Make sure width = height for perfect square
    final double itemSize = widget.size;
    
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _onPressedChange(true),
        onTapUp: (_) => _onPressedChange(false),
        onTapCancel: () => _onPressedChange(false),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : _isHovered ? 1.05 : 1.0,
              child: Transform.rotate(
                angle: _isPressed ? _rotateAnimation.value : 0.0,
                child: child,
              ),
            );
          },
          child: Container(
            width: itemSize,
            height: itemSize,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                    ? fgColor.withOpacity(0.3)
                    : bgColor.withOpacity(0.4),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: _isHovered 
                    ? const Offset(0, 4)
                    : const Offset(0, 2),
                  spreadRadius: _isHovered ? 1 : 0,
                ),
              ],
              gradient: _isHovered ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  Color.lerp(bgColor, fgColor, 0.3) ?? bgColor,
                ],
              ) : null,
            ),
            child: Stack(
              children: [
                if (_isHovered)
                  Positioned(
                    right: -5,
                    bottom: -5,
                    child: Icon(
                      widget.icon,
                      size: itemSize * 0.5,
                      color: fgColor.withOpacity(0.1),
                    ),
                  ),
                // Center both the icon and text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(_isHovered ? 12 : 8),
                        decoration: BoxDecoration(
                          color: _isHovered 
                            ? fgColor.withOpacity(0.2)
                            : fgColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          size: itemSize * (_isHovered ? 0.28 : 0.25),
                          color: fgColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title with animation
                      SizedBox(
                        width: itemSize - 16, // Give some margin for text
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: textTheme.bodyMedium?.copyWith(
                            color: fgColor,
                            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                            fontSize: _isHovered ? 14 : 13,
                          ) ?? const TextStyle(),
                          textAlign: TextAlign.center,
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Provides a set of predefined category colors for visual variety
class CategoryColors {
  static List<Color> backgroundColors = [
    Colors.red.shade50,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.amber.shade50,
    Colors.purple.shade50,
    Colors.teal.shade50,
    Colors.orange.shade50,
    Colors.indigo.shade50,
    Colors.pink.shade50,
    Colors.cyan.shade50,
  ];
  
  static List<Color> foregroundColors = [
    Colors.red.shade600,
    Colors.blue.shade600,
    Colors.green.shade600,
    Colors.amber.shade700,
    Colors.purple.shade600,
    Colors.teal.shade600,
    Colors.orange.shade700,
    Colors.indigo.shade600,
    Colors.pink.shade600,
    Colors.cyan.shade700,
  ];
  
  /// Get a color pair based on index
  static Map<String, Color> getColorPair(int index) {
    final bgIndex = index % backgroundColors.length;
    return {
      'background': backgroundColors[bgIndex],
      'foreground': foregroundColors[bgIndex],
    };
  }
} 