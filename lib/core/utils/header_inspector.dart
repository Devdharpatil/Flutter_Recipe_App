import 'package:flutter/material.dart';

/// Utility class to help visually inspect header consistency across the app
/// 
/// Only for debugging and testing purposes.
class HeaderInspector {
  /// Toggles a visual overlay that shows header measurements and details
  static bool showDebugOverlay = false;
  
  /// Distance from top to header title text
  static double? titleTopOffset;
  
  /// Width of the title area
  static double? titleWidth;
  
  /// Background color of the header
  static Color? headerBackgroundColor;
  
  /// Draw a debug overlay on top of the header
  static Widget debugHeaderOverlay(BuildContext context) {
    if (!showDebugOverlay) return const SizedBox.shrink();
    
    final headerInfo = _getHeaderInfo();
    final theme = Theme.of(context);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Header Inspection',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Title top offset: ${headerInfo.titleTopOffset?.toStringAsFixed(1) ?? 'unknown'}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Title width: ${headerInfo.titleWidth?.toStringAsFixed(1) ?? 'unknown'}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'BG Color: ${headerInfo.backgroundColor?.toString() ?? 'unknown'}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Theme mode: ${theme.brightness == Brightness.dark ? 'dark' : 'light'}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Record information about the current header
  static void recordHeaderInfo({
    double? titleTopOffset,
    double? titleWidth, 
    Color? backgroundColor,
  }) {
    HeaderInspector.titleTopOffset = titleTopOffset;
    HeaderInspector.titleWidth = titleWidth;
    HeaderInspector.headerBackgroundColor = backgroundColor;
  }
  
  /// Get current header information
  static _HeaderInfo _getHeaderInfo() {
    return _HeaderInfo(
      titleTopOffset: titleTopOffset,
      titleWidth: titleWidth,
      backgroundColor: headerBackgroundColor,
    );
  }
}

class _HeaderInfo {
  final double? titleTopOffset;
  final double? titleWidth;
  final Color? backgroundColor;
  
  _HeaderInfo({
    this.titleTopOffset,
    this.titleWidth,
    this.backgroundColor,
  });
} 