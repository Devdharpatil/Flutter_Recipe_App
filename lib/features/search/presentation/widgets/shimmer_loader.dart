import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'search_theme.dart';

class ShimmerLoader extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Shimmer.fromColors(
      baseColor: baseColor ?? colorScheme.surfaceVariant.withOpacity(0.3),
      highlightColor: highlightColor ?? colorScheme.surfaceVariant.withOpacity(0.1),
      period: period ?? const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(SearchThemeRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;
  final bool hasShadow;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: hasShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
    );
  }
}

class SearchSuggestionShimmer extends StatelessWidget {
  const SearchSuggestionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
      ],
      child: ShimmerLoader(
        child: Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  const ShimmerCircle(size: 24, hasShadow: true),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerContainer(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      ShimmerContainer(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentSearchesShimmer extends StatelessWidget {
  const RecentSearchesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
      ],
      child: ShimmerLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ShimmerContainer(
                width: 150,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const ShimmerCircle(size: 24, hasShadow: true),
                        const SizedBox(width: 16),
                        ShimmerContainer(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    const ShimmerCircle(size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrendingSearchesShimmer extends StatelessWidget {
  const TrendingSearchesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ShimmerLoader(
              child: ShimmerContainer(
                width: 150,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              padding: const EdgeInsets.only(left: 16),
              itemBuilder: (context, index) {
                return Animate(
                  effects: [
                    FadeEffect(
                      delay: Duration(milliseconds: 100 * index),
                      duration: const Duration(milliseconds: 400),
                    ),
                    SlideEffect(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                      delay: Duration(milliseconds: 100 * index),
                      duration: const Duration(milliseconds: 400),
                    ),
                  ],
                  child: ShimmerLoader(
                    period: Duration(milliseconds: 1500 + (200 * index)),
                    child: ShimmerContainer(
                      width: 150,
                      height: 120,
                      margin: const EdgeInsets.only(right: 12),
                      borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryGridShimmer extends StatelessWidget {
  const CategoryGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ShimmerLoader(
              child: ShimmerContainer(
                width: 180,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Animate(
                  effects: [
                    FadeEffect(
                      delay: Duration(milliseconds: 80 * index),
                      duration: const Duration(milliseconds: 500),
                    ),
                    ScaleEffect(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      delay: Duration(milliseconds: 80 * index),
                      duration: const Duration(milliseconds: 500),
                    ),
                  ],
                  child: ShimmerLoader(
                    period: Duration(milliseconds: 1500 + (150 * index)),
                    child: ShimmerContainer(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 