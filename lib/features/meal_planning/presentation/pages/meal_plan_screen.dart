import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/meal_plan.dart';
import '../bloc/meal_plan_bloc.dart';
import '../bloc/meal_plan_event.dart';
import '../bloc/meal_plan_state.dart';
import '../widgets/compact_meal_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/meal_card.dart';
import '../widgets/meal_slot.dart';
import '../widgets/view_mode_selector.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_event.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_state.dart';
import '../../../../core/widgets/app_header.dart';

// Custom persistent header delegate for view mode and date selector
class _ViewModeDateSelectorHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ColorScheme colorScheme;
  final ViewMode viewMode;
  final DateTime selectedDate;
  final Function(ViewMode) onViewModeChanged;
  final Function(DateTime) onDateChanged;

  _ViewModeDateSelectorHeaderDelegate({
    required this.colorScheme,
    required this.viewMode,
    required this.selectedDate,
    required this.onViewModeChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View mode selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ViewModeSelector(
              selectedMode: viewMode,
              onViewModeChanged: onViewModeChanged,
            ),
          ),

          // Date selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DateSelector(
              selectedDate: selectedDate,
              viewMode: viewMode,
              onDateChanged: onDateChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 116; // Adjust based on your UI needs

  @override
  double get minExtent => 116; // Same as maxExtent for this case

  @override
  bool shouldRebuild(covariant _ViewModeDateSelectorHeaderDelegate oldDelegate) {
    return oldDelegate.viewMode != viewMode ||
        oldDelegate.selectedDate != selectedDate ||
        oldDelegate.colorScheme != colorScheme;
  }
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  @override
  void initState() {
    super.initState();
    // Load meal plans when screen is shown
    context.read<MealPlanBloc>().add(const LoadMealPlans());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: BlocBuilder<MealPlanBloc, MealPlanState>(
          builder: (context, state) {
            if (state.isLoading && state.mealPlans.isEmpty) {
              return _buildLoadingView();
            }

            if (state.failure != null && state.mealPlans.isEmpty) {
              // Check for database setup issues
              if (state.failure!.message.contains('Database table is missing') || 
                  state.failure!.message.contains('relation "public.meal_plans" does not exist')) {
                return _buildDatabaseSetupErrorView(context);
              }
              
              return ErrorView(
                message: state.failure!.message,
                onRetry: () {
                  context.read<MealPlanBloc>().add(const LoadMealPlans());
                },
              );
            }

            return _buildContent(context, state);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to recipe search specifically for meal planning
          context.push('/search?forMealPlan=true');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MealPlanState state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Use the consistent AppHeader with proper styling that matches Settings screen
        AppHeader(
          title: 'Meal Planner',
          subtitle: 'Plan your meals for the week',
          isPinned: true,
          expandedHeight: 100, // Match Settings screen exactly
          backgroundColor: colorScheme.background, // Ensure it's the same as Settings
          actions: [
            // Stylized search button with proper color and positioning
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onBackground,
                  size: 24,
                ),
                onPressed: () {
                  context.push('/search');
                },
                tooltip: 'Search recipes',
              ),
            ),
          ],
        ),
        
        // View mode and date selection
        SliverPersistentHeader(
          pinned: true,
          delegate: _ViewModeDateSelectorHeaderDelegate(
            colorScheme: colorScheme,
            viewMode: state.viewMode,
            selectedDate: state.selectedDate,
            onViewModeChanged: (mode) {
              context.read<MealPlanBloc>().add(ChangeViewMode(mode));
            },
            onDateChanged: (date) {
              context.read<MealPlanBloc>().add(ChangeSelectedDate(date));
            },
          ),
        ),

        // Meal plan content in a sliver
        SliverFillRemaining(
          hasScrollBody: true,
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<MealPlanBloc>().add(const LoadMealPlans());
            },
            child: _buildMealPlanContent(context, state),
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlanContent(BuildContext context, MealPlanState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (state.viewMode) {
      case ViewMode.daily:
        return _buildDailyView(context, state);
      case ViewMode.weekly:
        return _buildWeeklyView(context, state);
      case ViewMode.monthly:
        return _buildMonthlyView(context, state);
    }
  }

  Widget _buildDailyView(BuildContext context, MealPlanState state) {
    // Wrap with SingleChildScrollView to prevent overflow
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: _buildDailyContent(context, state),
    );
  }

  Widget _buildWeeklyView(BuildContext context, MealPlanState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Calculate week dates
    final selectedDate = state.selectedDate;
    final weekday = selectedDate.weekday;
    final firstDayOfWeek = selectedDate.subtract(Duration(days: weekday - 1));
    
    final weekDates = List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );

    return DefaultTabController(
      length: 7,
      initialIndex: weekday - 1, // Select current day tab
      child: Column(
        children: [
          // Week days tabs - Premium redesign with luxury appearance
          Container(
            height: 100, // Increased height for more presence
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent, // Custom indicator
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              tabs: weekDates.map((date) {
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _isSameDay(date, selectedDate);
                
                return Tab(
                  height: 90,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: 54, // Fixed width for consistency
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withBlue(colorScheme.primary.blue + 20),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.surfaceVariant.withOpacity(0.3),
                                colorScheme.surfaceVariant.withOpacity(0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: -2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                      border: isSelected 
                          ? Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 0.6,
                            )
                          : isToday
                              ? Border.all(
                                  color: colorScheme.primary.withOpacity(0.4),
                                  width: 1.5,
                                )
                              : Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 0.5,
                                ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day of week label with premium styling
                        Text(
                          DateFormat('E').format(date)[0], // Just the first letter
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface.withOpacity(0.8),
                            shadows: isSelected
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        
                        // Day number with elegant styling
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            date.day.toString(),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: -0.5,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface,
                              shadows: isSelected
                                  ? [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        
                        // Today indicator or active meals indicator
                        if (isToday && !isSelected)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          )
                        else if (!isToday && !isSelected && _hasMealsForDate(date, state))
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onTap: (index) {
                // Add haptic feedback for premium feel
                HapticFeedback.lightImpact();
                // Change selected date
                context
                    .read<MealPlanBloc>()
                    .add(ChangeSelectedDate(weekDates[index]));
              },
            ),
          ),
          
          // Day content in tab view - This is the main content area
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(), // Smoother scrolling
              children: weekDates.map((date) {
                // Wrap with SingleChildScrollView to prevent overflow
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildDailyContent(
                    context,
                    state.copyWith(selectedDate: date),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView(BuildContext context, MealPlanState state) {
    // TODO: Implement monthly calendar view
    return Center(
      child: Text(
        'Monthly view coming soon',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // View mode loading
        const CustomShimmer(height: 50, width: double.infinity),
        const SizedBox(height: 16),
        
        // Date selector loading
        const CustomShimmer(height: 60, width: double.infinity),
        const SizedBox(height: 24),
        
        // Meal type loading (repeat for each meal type)
        for (int i = 0; i < 4; i++) ...[
          Row(
            children: const [
              CustomShimmer(height: 24, width: 24),
              SizedBox(width: 8),
              CustomShimmer(height: 24, width: 100),
            ],
          ),
          const SizedBox(height: 12),
          const CustomShimmer(height: 100, width: double.infinity),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildDatabaseSetupErrorView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_rounded,
              size: 64,
              color: colorScheme.error.withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            Text(
              'Database Setup Required',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'The meal planning feature requires setting up a database table. Please run the SQL script in your Supabase project.',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Steps to set up:',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Go to your Supabase project dashboard\n'
                    '2. Navigate to the SQL Editor\n'
                    '3. Copy and paste the SQL script below\n'
                    '4. Run the SQL query\n'
                    '5. Return to the app and try again',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copySqlToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy SQL'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _shareSqlScript(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share SQL'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<MealPlanBloc>().add(const LoadMealPlans());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copySqlToClipboard(BuildContext context) async {
    try {
      final String sqlScript = await rootBundle.loadString('create_meal_plans_table.sql');
      await Clipboard.setData(ClipboardData(text: sqlScript));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SQL script copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Fallback to hardcoded SQL if asset loading fails
      final String fallbackSql = '''
-- Create meal_plans table for storing user's meal planning data
CREATE TABLE IF NOT EXISTS public.meal_plans (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recipe_id INTEGER NOT NULL,
  recipe_title TEXT NOT NULL,
  recipe_image TEXT NOT NULL,
  date DATE NOT NULL,
  meal_type TEXT NOT NULL,
  servings INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  
  -- Add constraint to ensure valid meal_type values
  CONSTRAINT meal_type_check CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack'))
);

-- Create index for faster queries by date and user
CREATE INDEX IF NOT EXISTS meal_plans_user_date_idx ON public.meal_plans (user_id, date);
CREATE INDEX IF NOT EXISTS meal_plans_recipe_idx ON public.meal_plans (user_id, recipe_id);

-- Set up RLS (Row Level Security)
ALTER TABLE public.meal_plans ENABLE ROW LEVEL SECURITY;

-- Policies for row-level security
CREATE POLICY meal_plans_select_policy ON public.meal_plans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY meal_plans_insert_policy ON public.meal_plans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY meal_plans_update_policy ON public.meal_plans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY meal_plans_delete_policy ON public.meal_plans FOR DELETE USING (auth.uid() = user_id);
''';
      
      await Clipboard.setData(ClipboardData(text: fallbackSql));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SQL script copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  Future<void> _shareSqlScript(BuildContext context) async {
    try {
      String sqlScript;
      try {
        sqlScript = await rootBundle.loadString('create_meal_plans_table.sql');
      } catch (e) {
        // Fallback to hardcoded SQL if asset loading fails
        sqlScript = '''
-- Create meal_plans table for storing user's meal planning data
CREATE TABLE IF NOT EXISTS public.meal_plans (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recipe_id INTEGER NOT NULL,
  recipe_title TEXT NOT NULL,
  recipe_image TEXT NOT NULL,
  date DATE NOT NULL,
  meal_type TEXT NOT NULL,
  servings INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  
  -- Add constraint to ensure valid meal_type values
  CONSTRAINT meal_type_check CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack'))
);

-- Create index for faster queries by date and user
CREATE INDEX IF NOT EXISTS meal_plans_user_date_idx ON public.meal_plans (user_id, date);
CREATE INDEX IF NOT EXISTS meal_plans_recipe_idx ON public.meal_plans (user_id, recipe_id);

-- Set up RLS (Row Level Security)
ALTER TABLE public.meal_plans ENABLE ROW LEVEL SECURITY;

-- Policies for row-level security
CREATE POLICY meal_plans_select_policy ON public.meal_plans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY meal_plans_insert_policy ON public.meal_plans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY meal_plans_update_policy ON public.meal_plans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY meal_plans_delete_policy ON public.meal_plans FOR DELETE USING (auth.uid() = user_id);
''';
      }
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/create_meal_plans_table.sql');
      await file.writeAsString(sqlScript);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SQL script to create meal_plans table',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing SQL script: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToAddMeal(
    BuildContext context,
    DateTime date,
    MealType mealType,
  ) {
    // Navigate to search screen with parameters
    context.push(
      '/search?forMealPlan=true&date=${date.toIso8601String()}&mealType=${mealType.name}',
    );
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Extract daily content to a separate method that returns only the content, not ScrollView
  Widget _buildDailyContent(BuildContext context, MealPlanState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedDate = state.selectedDate;
    final dateFormat = DateFormat('EEEE, MMMM d');

    // Filter meal plans for the selected date
    final filteredMealPlans = state.mealPlans
        .where((mealPlan) => _isSameDay(mealPlan.date, selectedDate))
        .toList();

    // Group meal plans by meal type
    final mealsByType = <MealType, List<MealPlan>>{};
    for (final mealType in MealType.values) {
      mealsByType[mealType] = filteredMealPlans
          .where((mealPlan) => mealPlan.mealType == mealType)
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Text(
            dateFormat.format(selectedDate),
            style: textTheme.titleLarge?.copyWith( // Changed from headlineSmall to titleLarge
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // Prevent text overflow
          ),
          const SizedBox(height: 16), // Reduced from 24

          // Meal sections
          ...MealType.values.map((mealType) {
            final meals = mealsByType[mealType] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16), // Add bottom padding instead of SizedBox
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal type header - redesigned to be text-only with divider
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _getMealTypeColor(mealType).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      color: _getMealTypeColor(mealType).withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      mealType.displayName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // Meal cards or empty slot
                  if (meals.isEmpty)
                    MealSlot(
                      date: selectedDate,
                      mealType: mealType,
                      onTap: () {
                        // Navigate to recipe search for this meal slot
                        _navigateToAddMeal(context, selectedDate, mealType);
                      },
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meals.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8), // Reduced from 12
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return CompactMealCard(
                          meal: meal,
                          onTap: () {
                            // Navigate to recipe details
                            context.push('/recipe/${meal.recipeId}');
                          },
                          onDelete: () {
                            // Delete meal plan
                            context.read<MealPlanBloc>().add(DeleteMealPlan(meal));
                          },
                          onUpdate: (updatedMeal) {
                            // Update meal plan with new date
                            context.read<MealPlanBloc>().add(UpdateMealPlan(updatedMeal));
                          },
                          onFavoriteToggle: (isFavorite) {
                            // Connect to the UserFavoritesBloc to toggle favorite status
                            context.read<UserFavoritesBloc>().add(
                              ToggleFavorite(
                                recipeId: meal.recipeId,
                                currentStatus: !isFavorite, // inverted because we're toggling
                              ),
                            );
                            
                            // Update local UI state through MealPlanBloc
                            context.read<MealPlanBloc>().add(
                              ToggleFavoriteMealPlan(
                                recipeId: meal.recipeId,
                                isFavorite: isFavorite,
                              ),
                            );
                          },
                          isFavorite: meal.isFavorite,
                        );
                      },
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.blue;
      case MealType.snack:
        return Colors.purple;
    }
  }

  bool _hasMealsForDate(DateTime date, MealPlanState state) {
    // Format the date to compare with meal plan dates
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    // Check if any meal plan is scheduled for this date
    return state.mealPlans.any((mealPlan) {
      final mealPlanDate = DateFormat('yyyy-MM-dd').format(mealPlan.date);
      return mealPlanDate == dateString;
    });
  }
} 