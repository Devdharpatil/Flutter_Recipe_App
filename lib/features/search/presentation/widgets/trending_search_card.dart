import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'search_theme.dart';

class TrendingSearchCard extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool isTrending;
  final Color? gradientStartColor;
  final Color? gradientEndColor;

  const TrendingSearchCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.onTap,
    this.isTrending = true,
    this.gradientStartColor,
    this.gradientEndColor,
  });

  @override
  State<TrendingSearchCard> createState() => _TrendingSearchCardState();
}

class _TrendingSearchCardState extends State<TrendingSearchCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Hero(
        tag: 'trending_${widget.title}',
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(SearchThemeRadius.large),
            elevation: 0,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(SearchThemeRadius.large),
              splashColor: colorScheme.primary.withOpacity(0.1),
              child: Ink(
                height: 120,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: _isHovered 
                        ? colorScheme.primary.withOpacity(0.3) 
                        : Colors.transparent,
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image with fallback gradient
                      if (widget.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: widget.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildGradientBackground(context),
                          errorWidget: (context, url, error) => _buildGradientBackground(context),
                        )
                      else
                        _buildGradientBackground(context),
                      
                      // Overlay gradient for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Animated overlay for hover effect
                      AnimatedOpacity(
                        opacity: _isHovered ? 0.15 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.isTrending) ...[
                              const SizedBox(height: 4),
                              _buildTrendingIndicator(colorScheme),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingIndicator(ColorScheme colorScheme) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Icon(
              Icons.trending_up,
              size: 16,
              color: Colors.white.withOpacity(0.6 + 0.4 * _pulseController.value),
            );
          },
        ),
        const SizedBox(width: 4),
        Text(
          'Trending',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.gradientStartColor ?? colorScheme.primary.withOpacity(0.7),
            widget.gradientEndColor ?? colorScheme.primary,
          ],
        ),
      ),
    );
  }
}

class FallbackTrendingImages {
  static const Map<String, String> images = {
    'Pasta': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&auto=format&fit=crop',
    'Italian': 'https://images.unsplash.com/photo-1595295333158-4742f28fbd85?w=800&auto=format&fit=crop',
    'Chicken': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800&auto=format&fit=crop',
    'Vegetarian': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop',
    'Dessert': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=800&auto=format&fit=crop',
    'Quick Meals': 'https://images.unsplash.com/photo-1484980972926-edee96e0960d?w=800&auto=format&fit=crop',
    'Breakfast': 'https://images.unsplash.com/photo-1533920379810-6bedac9e9f65?w=800&auto=format&fit=crop',
    'Healthy': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800&auto=format&fit=crop',
    'Soup': 'https://images.unsplash.com/photo-1594756202469-9ff9799b2e4e?w=800&auto=format&fit=crop',
    'Salad': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop',
    'Baking': 'https://images.unsplash.com/photo-1486427944299-d1955d23e34d?w=800&auto=format&fit=crop',
    'Vegan': 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?w=800&auto=format&fit=crop',
    'Keto': 'https://images.unsplash.com/photo-1585937421612-70a008356c36?w=800&auto=format&fit=crop',
    'Gluten Free': 'https://images.unsplash.com/photo-1612728442619-bcc77b0be538?w=800&auto=format&fit=crop',
    'Low Carb': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800&auto=format&fit=crop',
  };

  static String getImageUrl(String category) {
    // First check the exact match
    if (images.containsKey(category)) {
      return images[category]!;
    }
    
    // If no exact match, try a case-insensitive match
    final lowercaseCategory = category.toLowerCase();
    for (final entry in images.entries) {
      if (entry.key.toLowerCase() == lowercaseCategory) {
        return entry.value;
      }
    }
    
    // If still no match, return a default image
    return 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800&auto=format&fit=crop';
  }
} 