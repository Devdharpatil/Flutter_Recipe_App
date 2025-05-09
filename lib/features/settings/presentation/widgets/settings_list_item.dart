import 'package:flutter/material.dart';

/// A beautiful, customized list item for the settings screens.
/// 
/// Features:
/// - Animated highlight on tap
/// - Support for leading icon, title, subtitle and trailing widget
/// - Consistent styling with app's premium design language
class SettingsListItem extends StatefulWidget {
  final IconData leadingIcon;
  final Color? leadingIconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  
  const SettingsListItem({
    super.key,
    required this.leadingIcon,
    this.leadingIconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<SettingsListItem> createState() => _SettingsListItemState();
}

class _SettingsListItemState extends State<SettingsListItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
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
    
    final titleColor = widget.isDestructive 
        ? colorScheme.error
        : colorScheme.onSurface;
    
    final leadingColor = widget.isDestructive
        ? colorScheme.error
        : widget.leadingIconColor ?? colorScheme.primary;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
          _animationController.forward();
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          _animationController.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
          _animationController.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed
                ? colorScheme.surfaceVariant.withOpacity(0.5)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Leading icon with animated gradient background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      leadingColor.withOpacity(0.2),
                      leadingColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.leadingIcon,
                  color: leadingColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Trailing widget (default: forward icon)
              widget.trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
} 