import 'package:flutter/material.dart';

/// A container for grouping related settings items with a title.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets padding;
  
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.only(top: 16, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: padding.top, bottom: 8),
          child: Row(
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.5),
                        colorScheme.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...children,
        SizedBox(height: padding.bottom),
      ],
    );
  }
} 