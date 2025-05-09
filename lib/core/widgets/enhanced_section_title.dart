import 'package:flutter/material.dart';

/// A beautifully designed section title with optional "See All" button.
class EnhancedSectionTitle extends StatelessWidget {
  /// The title of the section
  final String title;
  
  /// Optional emoji to display next to title
  final String? emoji;
  
  /// Callback when the "See All" button is tapped
  final VoidCallback? onSeeAllPressed;
  
  /// Optional custom text for the "See All" button
  final String seeAllText;
  
  /// Whether to animate the "See All" button on hover
  final bool animateOnHover;
  
  const EnhancedSectionTitle({
    Key? key,
    required this.title,
    this.emoji,
    this.onSeeAllPressed,
    this.seeAllText = 'See all',
    this.animateOnHover = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with optional emoji
          Row(
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              if (emoji != null) ...[
                const SizedBox(width: 6),
                Text(
                  emoji!,
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ],
          ),
          
          // See All button (if callback provided)
          if (onSeeAllPressed != null)
            _SeeAllButton(
              text: seeAllText,
              onPressed: onSeeAllPressed!,
              animate: animateOnHover,
            ),
        ],
      ),
    );
  }
}

class _SeeAllButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool animate;

  const _SeeAllButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.animate = true,
  }) : super(key: key);

  @override
  State<_SeeAllButton> createState() => _SeeAllButtonState();
}

class _SeeAllButtonState extends State<_SeeAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered && widget.animate
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: textTheme.bodyMedium?.copyWith(
                  color: _isHovered && widget.animate
                      ? colorScheme.primary
                      : colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 