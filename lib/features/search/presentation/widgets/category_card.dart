import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'search_theme.dart';

class CategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  
  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });
  
  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Use provided color or fallback to a theme color
    final bgColor = widget.backgroundColor ?? 
        colorScheme.primaryContainer.withOpacity(0.7);
    
    final textColor = colorScheme.onBackground;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(SearchThemeRadius.large),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            splashColor: colorScheme.primary.withOpacity(0.1),
            child: Ink(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                boxShadow: _isHovered 
                  ? [
                      BoxShadow(
                        color: bgColor.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : SearchThemeShadows.small(context),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bgColor.withOpacity(_isHovered ? 0.9 : 0.7),
                    bgColor.withOpacity(_isHovered ? 1.0 : 0.9),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon container
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15 + 0.05 * _pulseController.value),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: bgColor.withOpacity(0.3),
                                blurRadius: 8 + 4 * _pulseController.value,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Category title
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate(
      target: _isHovered ? 1 : 0,
      effects: [
        ShimmerEffect(
          duration: const Duration(seconds: 2),
          color: Colors.white.withOpacity(0.2),
          size: 0.4,
          delay: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class CategoryIcons {
  static final Map<String, IconData> icons = {
    'Quick & Easy': Icons.timer_outlined,
    'Budget Friendly': Icons.savings_outlined,
    'Healthy Options': Icons.favorite_border,
    'Seasonal': Icons.eco_outlined,
    'Comfort Food': Icons.nightlife_outlined,
    'Kid Friendly': Icons.child_care_outlined,
    'Dinner Party': Icons.celebration_outlined,
    'Date Night': Icons.local_bar_outlined,
  };

  static IconData getIcon(String category) {
    return icons[category] ?? Icons.food_bank_outlined;
  }
}

class CategoryColors {
  static List<Color> getGradientColors(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Create a visually appealing rotation of colors
    switch (index % 6) {
      case 0:
        return [
          colorScheme.primary.withOpacity(0.7),
          colorScheme.primary,
        ];
      case 1:
        return [
          colorScheme.secondary.withOpacity(0.7),
          colorScheme.secondary,
        ];
      case 2:
        return [
          colorScheme.tertiary.withOpacity(0.7),
          colorScheme.tertiary,
        ];
      case 3:
        return [
          colorScheme.primaryContainer.withOpacity(0.9),
          colorScheme.primary.withOpacity(0.7),
        ];
      case 4:
        return [
          colorScheme.secondaryContainer.withOpacity(0.9),
          colorScheme.secondary.withOpacity(0.7),
        ];
      default:
        return [
          colorScheme.tertiaryContainer.withOpacity(0.9),
          colorScheme.tertiary.withOpacity(0.7),
        ];
    }
  }
} 