import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OnboardingStepWidget extends StatefulWidget {
  final String imageUrl;
  final String? localImageAsset; // Optional local asset path
  final bool useNetworkFallback; // Whether to use network image as fallback
  final String title;
  final String description;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  final String nextButtonText;
  final Widget? customContent;

  const OnboardingStepWidget({
    super.key,
    required this.imageUrl,
    this.localImageAsset,
    this.useNetworkFallback = false,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    this.onBack,
    required this.onSkip,
    this.nextButtonText = 'Next',
    this.customContent,
  });

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _backgroundAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Longer duration
      vsync: this,
    );
    
    _imageScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _descriptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    
    // More subtle button animation
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to clamp opacity values between 0.0 and 1.0
  double _clampOpacity(double value) {
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final isLastPage = widget.currentPage == 3; // Is this the last page (index 3)?
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SafeArea(
            child: Stack(
              children: [
                // Enhanced background decorations
                Positioned(
                  right: -50 + (_backgroundAnimation.value * 30),
                  top: -30 + (_backgroundAnimation.value * 10),
                  child: Opacity(
                    opacity: _clampOpacity(0.08 * _backgroundAnimation.value),
                    child: Container(
                      width: isLastPage ? 350 : 280,
                      height: isLastPage ? 350 : 280,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(isLastPage ? 0.9 : 0.8),
                            AppTheme.primaryColor.withOpacity(isLastPage ? 0.3 : 0.2),
                          ],
                          stops: const [0.2, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -70 + (_backgroundAnimation.value * 30),
                  bottom: size.height * (isLastPage ? 0.15 : 0.25),
                  child: Opacity(
                    opacity: _clampOpacity(0.08 * _backgroundAnimation.value),
                    child: Container(
                      width: isLastPage ? 400 : 320,
                      height: isLastPage ? 400 : 320,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(isLastPage ? 0.8 : 0.7),
                            AppTheme.primaryColor.withOpacity(isLastPage ? 0.2 : 0.1),
                          ],
                          stops: const [0.2, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                
                // Additional decorations for the last page
                if (isLastPage) ...[
                  Positioned(
                    right: size.width * 0.2,
                    top: size.height * 0.25,
                    child: Opacity(
                      opacity: _clampOpacity(0.06 * _backgroundAnimation.value),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.lightGreen.withOpacity(0.7),
                              Colors.lightGreen.withOpacity(0.1),
                            ],
                            stops: const [0.2, 1.0],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size.width * 0.15,
                    top: size.height * 0.1,
                    child: Opacity(
                      opacity: _clampOpacity(0.05 * _backgroundAnimation.value),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.teal.withOpacity(0.6),
                              Colors.teal.withOpacity(0.1),
                            ],
                            stops: const [0.2, 1.0],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Main content with proper layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      
                      // Image with enhanced animation - only for pages 0-2
                      if (!isLastPage) ...[
                        Expanded(
                          flex: 5,
                          child: Transform.scale(
                            scale: _imageScaleAnimation.value,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                20 * (1 - _imageScaleAnimation.value),
                              ),
                              child: Opacity(
                                opacity: _clampOpacity(_imageScaleAnimation.value),
                                child: Hero(
                                  tag: 'onboarding_image_${widget.currentPage}',
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: _buildOptimizedImage(isLightMode),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // For the last page, add more space at the top
                      if (isLastPage)
                        SizedBox(height: size.height * 0.08),

                      // Title with enhanced animation
                      Transform.translate(
                        offset: Offset(
                          0,
                          30 * (1 - _titleAnimation.value),
                        ),
                        child: Opacity(
                          opacity: _clampOpacity(_titleAnimation.value),
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: AppTheme.primaryColor.withOpacity(0.15),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Description with enhanced animation
                      Transform.translate(
                        offset: Offset(
                          0,
                          20 * (1 - _descriptionAnimation.value),
                        ),
                        child: Opacity(
                          opacity: _clampOpacity(_descriptionAnimation.value),
                          child: Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isLightMode
                                ? AppTheme.secondaryTextColorLight
                                : AppTheme.secondaryTextColorDark,
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Custom content with animation if provided (in scrollable container if needed)
                      if (widget.customContent != null) ...[
                        Expanded(
                          flex: isLastPage ? 6 : 0,
                          child: isLastPage
                              ? SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Opacity(
                                    opacity: _clampOpacity(_descriptionAnimation.value),
                                    child: widget.customContent!,
                                  ),
                                )
                              : Opacity(
                                  opacity: _clampOpacity(_descriptionAnimation.value),
                                  child: widget.customContent!,
                                ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Enhanced progress indicator
                      Opacity(
                        opacity: _clampOpacity(_descriptionAnimation.value),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.totalPages,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: index == widget.currentPage ? 32 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: index == widget.currentPage
                                  ? AppTheme.primaryColor
                                  : isLightMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                boxShadow: index == widget.currentPage
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Next button with more subtle animation
                      FadeTransition(
                        opacity: _buttonAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: widget.onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 4,
                                shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.nextButtonText,
                                    style: const TextStyle(
                                      fontSize: 17, 
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (widget.nextButtonText == 'Next') ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Back and Skip buttons with animation
                      Opacity(
                        opacity: _clampOpacity(_buttonAnimation.value),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.onBack != null) ...[
                              TextButton.icon(
                                onPressed: widget.onBack,
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: isLightMode
                                    ? AppTheme.primaryTextColorLight
                                    : AppTheme.primaryTextColorDark,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const Spacer(),
                            ],
                            TextButton(
                              onPressed: widget.onSkip,
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: isLightMode
                                  ? AppTheme.primaryTextColorLight
                                  : AppTheme.primaryTextColorDark,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptimizedImage(bool isLightMode) {
    // Try to load local asset first if specified
    if (widget.localImageAsset != null) {
      return _buildImageWithErrorHandler(
        imageProvider: AssetImage(widget.localImageAsset!),
        isLightMode: isLightMode,
      );
    }
    // Otherwise use the standard imageUrl (asset or network)
    else if (widget.imageUrl.startsWith('assets/')) {
      return _buildImageWithErrorHandler(
        imageProvider: AssetImage(widget.imageUrl),
        isLightMode: isLightMode,
      );
    } 
    // Use network image (or as fallback)
    else {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isLightMode 
            ? Colors.grey[100] 
            : Colors.grey[900],
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: isLightMode 
            ? Colors.grey[100] 
            : Colors.grey[900],
          child: Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 60,
              color: isLightMode
                ? AppTheme.primaryTextColorLight.withOpacity(0.5)
                : AppTheme.primaryTextColorDark.withOpacity(0.5),
            ),
          ),
        ),
      );
    }
  }

  // Advanced error handling for asset images
  Widget _buildImageWithErrorHandler({
    required ImageProvider imageProvider,
    required bool isLightMode,
  }) {
    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Image error: $error');
        // If network fallback is enabled and we have a network URL, use it
        if (widget.useNetworkFallback && !widget.imageUrl.startsWith('assets/')) {
          return CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: isLightMode ? Colors.grey[100] : Colors.grey[900],
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildErrorPlaceholder(isLightMode),
          );
        } else {
          return _buildErrorPlaceholder(isLightMode);
        }
      },
    );
  }

  // Common error placeholder
  Widget _buildErrorPlaceholder(bool isLightMode) {
    return Container(
      color: isLightMode ? Colors.grey[100] : Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 60,
              color: isLightMode
                  ? AppTheme.primaryTextColorLight.withOpacity(0.5)
                  : AppTheme.primaryTextColorDark.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Image not available",
              style: TextStyle(
                color: isLightMode
                    ? AppTheme.primaryTextColorLight.withOpacity(0.5)
                    : AppTheme.primaryTextColorDark.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 