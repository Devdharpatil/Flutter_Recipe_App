import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PreferenceChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onToggle;
  final IconData? icon;
  final bool isCompact;

  const PreferenceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onToggle,
    this.icon,
    this.isCompact = false,
  });

  @override
  State<PreferenceChip> createState() => _PreferenceChipState();
}

class _PreferenceChipState extends State<PreferenceChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    // Use same text size as rest of app
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
      color: widget.isSelected 
          ? Colors.white 
          : isLightMode 
              ? AppTheme.secondaryTextColorLight 
              : AppTheme.secondaryTextColorDark,
    ) ?? TextStyle(
      fontSize: 15,
      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
      color: widget.isSelected 
          ? Colors.white 
          : isLightMode 
              ? AppTheme.secondaryTextColorLight 
              : AppTheme.secondaryTextColorDark,
    );
    
    return GestureDetector(
      onTap: widget.onToggle,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          // Tight padding for perfect content wrapping
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? AppTheme.primaryColor
                : isLightMode 
                    ? Colors.white 
                    : const Color(0xFF23272A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected 
                  ? AppTheme.primaryColor
                  : isLightMode 
                      ? const Color(0xFFBDBDBD) 
                      : const Color(0xFF616161),
              width: 1.5,
            ),
            boxShadow: _isPressed || widget.isSelected 
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(widget.isSelected ? 0.3 : 0.1),
                      blurRadius: widget.isSelected ? 10 : 4,
                      offset: const Offset(0, 3),
                      spreadRadius: widget.isSelected ? 1 : 0,
                    )
                  ] 
                : null,
          ),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.isSelected 
                        ? Colors.white 
                        : isLightMode 
                            ? AppTheme.secondaryTextColorLight 
                            : AppTheme.secondaryTextColorDark,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label,
                  style: textStyle,
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 