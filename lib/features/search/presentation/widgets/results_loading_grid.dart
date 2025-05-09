import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../home_discovery/presentation/widgets/grid_loading_recipe_card.dart';

class ResultsLoadingGrid extends StatelessWidget {
  const ResultsLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      highlightColor: colorScheme.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const GridLoadingRecipeCard(),
      ),
    );
  }
} 