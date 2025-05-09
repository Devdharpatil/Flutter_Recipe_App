import 'package:flutter/material.dart';
import 'search_theme.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? selectedColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomChip({
    super.key,
    required this.label,
    this.selected = false,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.selectedColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final bg = selected 
        ? (selectedColor ?? colorScheme.primary)
        : (backgroundColor ?? colorScheme.surfaceVariant.withOpacity(0.5));
    
    final textColor = selected
        ? (selectedColor != null ? Colors.white : colorScheme.onPrimary)
        : colorScheme.onSurfaceVariant;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(SearchThemeRadius.medium),
        splashColor: selected 
            ? Colors.white.withOpacity(0.1) 
            : colorScheme.primary.withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: borderRadius ?? BorderRadius.circular(SearchThemeRadius.medium),
            boxShadow: selected ? SearchThemeShadows.small(context) : null,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check,
                    size: 14,
                    color: textColor,
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

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      avatar: selected 
          ? Icon(Icons.check_circle_rounded, size: 18, color: colorScheme.onPrimary)
          : icon != null ? Icon(icon, size: 18, color: colorScheme.onSurfaceVariant) : null,
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: onSelected,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
} 