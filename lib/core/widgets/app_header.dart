import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/header_inspector.dart';

/// A premium, consistent header widget for app screens.
/// 
/// This component provides a beautiful SliverAppBar that can be used
/// across all app screens for a consistent premium look.
class AppHeader extends StatelessWidget {
  /// The title of the screen
  final String title;
  
  /// Optional subtitle to display below the title
  final String? subtitle;
  
  /// Whether the app bar should be pinned when scrolling
  final bool isPinned;
  
  /// Whether the app bar should be floating when scrolling
  final bool isFloating;
  
  /// The height of the expanded app bar
  final double expandedHeight;
  
  /// Actions to display in the app bar
  final List<Widget>? actions;
  
  /// Background color for the app bar (will use a gradient by default)
  final Color? backgroundColor;
  
  /// Whether to show a back button
  final bool showBackButton;
  
  /// Callback when the back button is pressed
  final VoidCallback? onBackPressed;
  
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.isPinned = true,
    this.isFloating = false,
    this.expandedHeight = 90,
    this.actions,
    this.backgroundColor,
    this.showBackButton = false,
    this.onBackPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bgColor = backgroundColor ?? colorScheme.background;
    
    // For debug inspection
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HeaderInspector.recordHeaderInfo(
          backgroundColor: bgColor,
          titleWidth: MediaQuery.of(context).size.width - (showBackButton ? 56 : 20) - 16,
          titleTopOffset: expandedHeight - 30,
        );
      });
    }
    
    return SliverAppBar(
      pinned: isPinned,
      floating: isFloating,
      expandedHeight: expandedHeight,
      backgroundColor: bgColor,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton 
        ? IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: colorScheme.onBackground,
            ),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          )
        : null,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: showBackButton ? 56 : 20, 
          bottom: 14,
          right: 16,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium title with gradient text
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withBlue(
                    (colorScheme.primary.blue + 15).clamp(0, 255)
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Optional subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.7),
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            color: bgColor,
          ),
        ),
      ),
    );
  }
}
