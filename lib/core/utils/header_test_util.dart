import 'package:flutter/material.dart';
import 'header_inspector.dart';

/// A class with methods for enabling header visual inspection
/// Only used during development for consistency testing
class HeaderTestUtil {
  /// Enable the debug overlay to visually inspect header consistency
  static void enableHeaderInspection() {
    HeaderInspector.showDebugOverlay = true;
  }
  
  /// Disable the debug overlay 
  static void disableHeaderInspection() {
    HeaderInspector.showDebugOverlay = false;
  }
  
  /// Visual debug overlay that can be added to any screen
  static Widget buildOverlay(BuildContext context) {
    return Stack(
      children: [
        HeaderInspector.debugHeaderOverlay(context),
      ],
    );
  }
  
  /// Get a wrapper widget that can be used to add the debug overlay to a screen
  static Widget Function(BuildContext, Widget) get debugOverlayBuilder {
    return (BuildContext context, Widget child) {
      return Stack(
        children: [
          child,
          if (HeaderInspector.showDebugOverlay)
            HeaderInspector.debugHeaderOverlay(context),
        ],
      );
    };
  }
} 