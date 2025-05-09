import 'package:flutter/material.dart';

/// Toggles debugging tools for visual inspection.
bool debugModeEnabled = false;

/// Shows an overlay that highlights the header area for debugging
/// This is for development use only to visually check header consistency
class HeaderDebugOverlay extends StatelessWidget {
  final Widget child;

  const HeaderDebugOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!debugModeEnabled) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100, // Reference height that should match all app headers
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.withOpacity(0.7),
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 14),
                    child: Container(
                      height: 22, // Title text height reference
                      width: 150, // Approximate title width
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 1),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A wrapper function to add the debug overlay to any widget
/// For example: debugWrap(MyWidget())
Widget debugWrap(Widget child) {
  return HeaderDebugOverlay(child: child);
}

/// Enables header debug overlay mode
void enableHeaderDebug() {
  debugModeEnabled = true;
}

/// Disables header debug overlay mode  
void disableHeaderDebug() {
  debugModeEnabled = false;
} 