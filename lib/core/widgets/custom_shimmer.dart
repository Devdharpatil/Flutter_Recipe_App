import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A custom shimmer loading indicator widget for content loading placeholders
class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmer({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Use surface and surfaceVariant colors from theme for shimmer effect
    final baseColor = colorScheme.surfaceVariant.withOpacity(0.4);
    final highlightColor = colorScheme.surface;

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
} 