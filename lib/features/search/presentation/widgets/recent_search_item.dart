import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'search_theme.dart';

class RecentSearchItem extends StatefulWidget {
  final String search;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const RecentSearchItem({
    super.key,
    required this.search,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<RecentSearchItem> createState() => _RecentSearchItemState();
}

class _RecentSearchItemState extends State<RecentSearchItem> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: SearchThemeAnimations.short,
        decoration: BoxDecoration(
          color: _isHovered ? colorScheme.surfaceVariant.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(SearchThemeRadius.medium),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(SearchThemeRadius.medium),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history,
                    size: 16,
                    color: colorScheme.primary.withOpacity(0.9),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                  effects: [
                    ScaleEffect(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      delay: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.search,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.onDelete != null)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Search'),
                          content: Text('Remove "${widget.search}" from your recent searches?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onDelete!();
                              },
                              child: const Text('REMOVE'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.7,
                      duration: SearchThemeAnimations.short,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isHovered ? colorScheme.surfaceVariant.withOpacity(0.3) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 