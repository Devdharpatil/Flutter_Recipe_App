import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A customizable user avatar widget that displays a user's profile image.
/// If no image is available, it shows a fallback icon or the first letter of the user's name.
class UserAvatar extends StatelessWidget {
  /// The URL of the user's profile image
  final String? imageUrl;

  /// The size of the avatar (both width and height)
  final double size;
  
  /// Fallback icon to display when no image is available
  final IconData? fallbackIcon;
  
  /// Fallback text to display when no image is available (usually first letter of name)
  final String fallbackText;

  /// Callback when the avatar is tapped
  final VoidCallback? onTap;

  /// Circle background color
  final Color? backgroundColor;

  /// Text/icon color
  final Color? foregroundColor;

  const UserAvatar({
    Key? key,
    this.imageUrl,
    this.size = 42,
    this.fallbackIcon,
    this.fallbackText = 'U',
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final bgColor = backgroundColor ?? colorScheme.primaryContainer;
    final fgColor = foregroundColor ?? colorScheme.onPrimaryContainer;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(bgColor, fgColor),
                errorWidget: (context, url, error) => _buildPlaceholder(bgColor, fgColor),
              )
            : _buildPlaceholder(bgColor, fgColor),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color bgColor, Color fgColor) {
    // Decide whether to show an icon or text
    return Container(
      color: bgColor,
      child: Center(
        child: fallbackIcon != null 
          ? Icon(
              fallbackIcon,
              size: size * 0.5,
              color: fgColor,
            )
          : Text(
              fallbackText,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
            ),
      ),
    );
  }
} 