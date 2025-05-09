import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../recipe_detail/domain/entities/recipe_detail.dart';
import '../../../recipe_detail/presentation/bloc/recipe_detail_bloc.dart';
import '../../../recipe_detail/presentation/bloc/recipe_detail_event.dart';
import '../../../recipe_detail/presentation/bloc/recipe_detail_state.dart';
import '../bloc/cooking_mode_bloc.dart';
import '../bloc/cooking_mode_event.dart';
import '../bloc/cooking_mode_state.dart';
import '../widgets/cooking_step_card.dart';

class CookingModeScreen extends StatefulWidget {
  final int recipeId;
  
  const CookingModeScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late PageController _pageController;
  bool _fullscreenMode = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    
    // Enable wakelock to keep screen on while cooking
    WakelockPlus.enable();
    
    // If we don't have recipe details yet, fetch them
    final recipeDetailState = context.read<RecipeDetailBloc>().state;
    if (recipeDetailState is! RecipeDetailLoaded) {
      context.read<RecipeDetailBloc>().add(
        FetchRecipeDetail(recipeId: widget.recipeId),
      );
    } else {
      // Initialize cooking mode with available recipe details
      context.read<CookingModeBloc>().add(
        InitializeCookingMode(recipe: recipeDetailState.recipe),
      );
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    
    // Disable wakelock when leaving the screen
    WakelockPlus.disable();
    
    // Exit fullscreen mode when leaving
    if (_fullscreenMode) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge, 
        overlays: SystemUiOverlay.values
      );
    }
    
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause timer when app goes to background
    final bloc = context.read<CookingModeBloc>();
    final currentState = bloc.state;
    
    if (currentState is CookingModeLoaded && currentState.isTimerActive) {
      if (state == AppLifecycleState.paused || 
          state == AppLifecycleState.inactive) {
        bloc.add(PauseTimer());
      }
    }
    
    super.didChangeAppLifecycleState(state);
  }
  
  void _toggleFullscreenMode() {
    setState(() {
      _fullscreenMode = !_fullscreenMode;
      
      if (_fullscreenMode) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge, 
          overlays: SystemUiOverlay.values
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.3),
            shape: const CircleBorder(),
          ),
          onPressed: () {
            context.read<CookingModeBloc>().add(ExitCookingMode());
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _fullscreenMode 
                  ? Icons.fullscreen_exit 
                  : Icons.fullscreen,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.3),
              shape: const CircleBorder(),
            ),
            onPressed: _toggleFullscreenMode,
          ),
        ],
      ),
      body: BlocListener<RecipeDetailBloc, RecipeDetailState>(
        listener: (context, state) {
          if (state is RecipeDetailLoaded) {
            // When recipe details are loaded, initialize cooking mode
            context.read<CookingModeBloc>().add(
              InitializeCookingMode(recipe: state.recipe),
            );
          }
        },
        child: BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
          builder: (context, recipeState) {
            if (recipeState is RecipeDetailLoading) {
              return const Center(child: LoadingIndicator());
            } else if (recipeState is RecipeDetailError) {
              return ErrorView(
                message: recipeState.failure.message,
                onRetry: () => context.read<RecipeDetailBloc>().add(
                  FetchRecipeDetail(recipeId: widget.recipeId),
                ),
              );
            } else if (recipeState is RecipeDetailLoaded) {
              return _buildCookingModeContent(recipeState.recipe);
            } else {
              return const Center(child: LoadingIndicator());
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildCookingModeContent(RecipeDetail recipe) {
    return BlocConsumer<CookingModeBloc, CookingModeState>(
      listener: (context, state) {
        if (state is CookingModeLoaded) {
          // Sync page controller with bloc state
          if (_pageController.hasClients && 
              _pageController.page?.round() != state.currentStepIndex) {
            _pageController.animateToPage(
              state.currentStepIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is CookingModeLoading || state is CookingModeInitial) {
          return _buildLoadingState();
        } else if (state is CookingModeLoaded) {
          return _buildLoadedState(context, state);
        } else if (state is CookingModeError) {
          return _buildErrorState(context, state.message);
        } else {
          return _buildErrorState(context, 'Unknown state');
        }
      },
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(child: LoadingIndicator());
  }
  
  Widget _buildLoadedState(BuildContext context, CookingModeLoaded state) {
    // Get steps from the recipe object in the state
    final steps = state.recipe.analyzedInstructions;
    
    if (steps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'No instructions available for this recipe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to Recipe'),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        
        // Main content - scrollable steps
        Positioned.fill(
          bottom: 80, // Make room for the navigation footer
          child: PageView.builder(
            controller: _pageController,
            itemCount: steps.length,
            onPageChanged: (index) {
              // Update bloc state when page changes
              context.read<CookingModeBloc>().add(GoToSpecificStep(stepIndex: index));
            },
            itemBuilder: (context, index) {
              return CookingStepCard(
                step: steps[index],
                stepNumber: index + 1,
                totalSteps: steps.length,
                isTimerActive: state.isTimerActive,
                timerRemainingSeconds: state.timerRemainingSeconds,
                onStartTimer: () {
                  final timerDuration = _extractTimingFromText(steps[index].step);
                  if (timerDuration != null) {
                    context.read<CookingModeBloc>().add(
                      StartTimer(durationInSeconds: timerDuration),
                    );
                  }
                },
                onPauseTimer: () => context.read<CookingModeBloc>().add(PauseTimer()),
                onResumeTimer: () => context.read<CookingModeBloc>().add(ResumeTimer()),
                onResetTimer: () => context.read<CookingModeBloc>().add(ResetTimer()),
              );
            },
          ),
        ),
        
        // Navigation footer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildNavigationFooter(context, state.currentStepIndex, steps.length),
        ),
        
        // Step progress indicator
        Positioned(
          top: kToolbarHeight + 16,
          left: 0,
          right: 0,
          child: _buildStepIndicator(state, steps.length),
        ),
      ],
    );
  }
  
  Widget _buildErrorState(BuildContext context, String message) {
    return ErrorView(
      message: message,
      onRetry: () => context.read<RecipeDetailBloc>().add(
        FetchRecipeDetail(recipeId: widget.recipeId),
      ),
    );
  }
  
  Widget _buildStepIndicator(CookingModeLoaded state, int totalSteps) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Step text above progress bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Step ${state.currentStepIndex + 1} of $totalSteps',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Progress bar with clean design
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (state.currentStepIndex + 1) / totalSteps,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationFooter(BuildContext context, int currentStep, int totalSteps) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: currentStep > 0
                    ? () => context.read<CookingModeBloc>().add(GoToPreviousStep())
                    : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Prev'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  disabledForegroundColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${currentStep + 1}/$totalSteps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Next/Finish button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: currentStep < totalSteps - 1
                    ? () => context.read<CookingModeBloc>().add(GoToNextStep())
                    : () {
                        // On the last step, exit cooking mode
                        context.read<CookingModeBloc>().add(ExitCookingMode());
                        context.pop();
                      },
                icon: Icon(
                  currentStep < totalSteps - 1 ? Icons.arrow_forward_rounded : Icons.check_rounded,
                ),
                label: Text(
                  currentStep < totalSteps - 1 ? 'Next' : 'Done',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  int? _extractTimingFromText(String text) {
    // Common patterns for cooking times
    final regexPatterns = [
      RegExp(r'(\d+)[\s-]*(minute|min)s?', caseSensitive: false),
      RegExp(r'(\d+)[\s-]*(hour|hr)s?', caseSensitive: false),
      RegExp(r'for[\s-]*(\d+)[\s-]*(minute|min)s?', caseSensitive: false),
      RegExp(r'for[\s-]*(\d+)[\s-]*(hour|hr)s?', caseSensitive: false),
    ];
    
    for (final regex in regexPatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = int.tryParse(match.group(1) ?? '');
        final unit = match.group(2)?.toLowerCase();
        
        if (value != null) {
          // Convert to seconds
          if (unit == 'hour' || unit == 'hr') {
            return value * 60 * 60; // hours to seconds
          } else {
            return value * 60; // minutes to seconds
          }
        }
      }
    }
    
    return null;
  }
} 