import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/meal_plan.dart';
import '../bloc/meal_plan_bloc.dart';
import '../bloc/meal_plan_event.dart';
import '../bloc/meal_plan_state.dart';
import '../widgets/compact_meal_card.dart';
import '../widgets/meal_slot.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_event.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_state.dart';

class CompactMealPlanScreen extends StatefulWidget {
  const CompactMealPlanScreen({Key? key}) : super(key: key);

  @override
  State<CompactMealPlanScreen> createState() => _CompactMealPlanScreenState();
}

class _CompactMealPlanScreenState extends State<CompactMealPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PageController? _dayPageController;
  final List<String> _viewModes = ['Daily', 'Weekly', 'Monthly'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newMode = ViewMode.values[_tabController.index];
        context.read<MealPlanBloc>().add(ChangeViewMode(newMode));
      }
    });
    
    // Initialize the day page controller with initially selected day index (today = 500)
    _dayPageController = PageController(initialPage: 500);
    
    // Load meal plans when screen is shown
    context.read<MealPlanBloc>().add(const LoadMealPlans());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _dayPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Planner'),
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search'),
                tooltip: 'Search for recipes',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: _viewModes.map((mode) => Tab(
                      text: mode,
                      height: 38,
                    )).toList(),
                    indicator: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: colorScheme.onPrimary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    padding: EdgeInsets.zero,
                    splashBorderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
          ),
          body: BlocBuilder<MealPlanBloc, MealPlanState>(
            builder: (context, state) {
              if (state.isLoading && state.mealPlans.isEmpty) {
                return _buildLoadingView();
              }

              if (state.failure != null && state.mealPlans.isEmpty) {
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

              return TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDailyView(context, state, constraints),
                  _buildWeeklyView(context, state, constraints),
                  _buildMonthlyView(context, state),
                ],
              );
            },
          ),
        );
      }
    );
  }

  Widget _buildDatabaseSetupErrorView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Center(
      child: SingleChildScrollView(
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
              'The meal planning feature requires database setup.',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
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
  
  Widget _buildLoadingView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date selector loading
        const CustomShimmer(height: 40, width: double.infinity),
        const SizedBox(height: 16),
        
        // Meal type loading
        for (int i = 0; i < 3; i++) ...[
          Row(
            children: const [
              CustomShimmer(height: 24, width: 24),
              SizedBox(width: 8),
              CustomShimmer(height: 24, width: 100),
            ],
          ),
          const SizedBox(height: 8),
          const CustomShimmer(height: 72, width: double.infinity),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDailyView(BuildContext context, MealPlanState state, BoxConstraints constraints) {
    // Ensure page controller is initialized
    if (_dayPageController == null) {
      _dayPageController = PageController(initialPage: 500);
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MealPlanBloc>().add(const LoadMealPlans());
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: _buildDateSelector(context, state),
            ),
            Expanded(
              child: PageView.builder(
                controller: _dayPageController!,
                // When page changes, update selected date in the bloc
                onPageChanged: (pageIndex) {
                  final newDate = _getDateFromPageIndex(pageIndex);
                  context.read<MealPlanBloc>().add(ChangeSelectedDate(newDate));
                },
                // Build page for each day
                itemBuilder: (context, pageIndex) {
                  final date = _getDateFromPageIndex(pageIndex);
                  return _buildDailyContent(
                    context,
                    state.copyWith(selectedDate: date),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView(BuildContext context, MealPlanState state, BoxConstraints constraints) {
    // Get current date info for the week view
    final today = DateTime.now();
    final weekday = today.weekday;
    final startOfWeek = today.subtract(Duration(days: weekday - 1));
    
    final weekDays = List.generate(
      7, 
      (index) => startOfWeek.add(Duration(days: index))
    );
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MealPlanBloc>().add(const LoadMealPlans());
      },
      child: SafeArea(
        child: Column(
          children: [
            // Date navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: _buildDateSelector(context, state),
            ),
            
            // Week days - Using flexible layout instead of fixed height
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: WeekdaySelector(
                weekDays: weekDays,
                selectedDate: state.selectedDate,
                onDateSelected: (date) {
                  context.read<MealPlanBloc>().add(ChangeSelectedDate(date));
                },
              ),
            ),
            
            // Daily content for selected day
            Expanded(
              child: _buildDailyContent(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyView(BuildContext context, MealPlanState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 48,
              color: colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Monthly view coming soon',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re working on this feature',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateSelector(BuildContext context, MealPlanState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleSmall;
    final selectedDate = state.selectedDate;
    
    String dateText;
    if (_isSameDay(selectedDate, DateTime.now())) {
      dateText = 'Today, ${DateFormat('MMMM d').format(selectedDate)}';
    } else {
      dateText = DateFormat('MMMM d, yyyy').format(selectedDate);
    }
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous day button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.viewMode == ViewMode.daily 
                ? () => _goToPreviousDay(context, state)
                : () => _navigateToPreviousDate(context, state),
            iconSize: 20,
            tooltip: 'Previous day',
          ),
          
          // Date display
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context, state),
              child: Center(
                child: Text(
                  dateText,
                  style: textStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Next day button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.viewMode == ViewMode.daily 
                ? () => _goToNextDay(context, state)
                : () => _navigateToNextDate(context, state),
            iconSize: 20,
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }
  
  Future<void> _showDatePicker(BuildContext context, MealPlanState state) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      context.read<MealPlanBloc>().add(ChangeSelectedDate(pickedDate));
    }
  }
  
  Widget _buildDailyContent(BuildContext context, MealPlanState state) {
    final selectedDate = state.selectedDate;
    final colorScheme = Theme.of(context).colorScheme;
    
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
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: MealType.values.length,
      itemBuilder: (context, index) {
        final mealType = MealType.values[index];
        final meals = mealsByType[mealType] ?? [];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal type header with icon
              MealTypeHeader(
                mealType: mealType,
                mealCount: meals.length,
                onAddPressed: () => _navigateToAddMeal(context, selectedDate, mealType),
              ),
              
              // Meal cards or empty slot
              if (meals.isEmpty)
                MealSlot(
                  date: selectedDate,
                  mealType: mealType,
                  onTap: () => _navigateToAddMeal(context, selectedDate, mealType),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return CompactMealCard(
                      meal: meal,
                      onTap: () => context.push('/recipe/${meal.recipeId}'),
                      onDelete: () => context.read<MealPlanBloc>().add(DeleteMealPlan(meal)),
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
      },
    );
  }
  
  void _navigateToAddMeal(BuildContext context, DateTime date, MealType mealType) {
    context.push(
      '/search?forMealPlan=true&date=${date.toIso8601String()}&mealType=${mealType.name}',
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get the date for a specific page index
  DateTime _getDateFromPageIndex(int index) {
    // Use a base index (e.g., 500) as "today" and calculate offset days
    return DateTime.now().add(Duration(days: index - 500));
  }

  // Custom methods for navigating between days
  void _goToNextDay(BuildContext context, MealPlanState state) {
    if (_dayPageController != null && _dayPageController!.hasClients) {
      _dayPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Fallback: directly update date in bloc
      _navigateToNextDate(context, state);
    }
  }

  void _goToPreviousDay(BuildContext context, MealPlanState state) {
    if (_dayPageController != null && _dayPageController!.hasClients) {
      _dayPageController!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Fallback: directly update date in bloc
      _navigateToPreviousDate(context, state);
    }
  }

  void _navigateToPreviousDate(BuildContext context, MealPlanState state) {
    final DateTime newDate;
    
    switch (state.viewMode) {
      case ViewMode.daily:
        newDate = state.selectedDate.subtract(const Duration(days: 1));
        break;
      case ViewMode.weekly:
        newDate = state.selectedDate.subtract(const Duration(days: 7));
        break;
      case ViewMode.monthly:
        // Go to previous month, same day
        final month = state.selectedDate.month;
        final year = state.selectedDate.year;
        
        if (month == 1) {
          newDate = DateTime(year - 1, 12, state.selectedDate.day);
        } else {
          newDate = DateTime(year, month - 1, state.selectedDate.day);
        }
        break;
    }
    
    context.read<MealPlanBloc>().add(ChangeSelectedDate(newDate));
  }
  
  void _navigateToNextDate(BuildContext context, MealPlanState state) {
    final DateTime newDate;
    
    switch (state.viewMode) {
      case ViewMode.daily:
        newDate = state.selectedDate.add(const Duration(days: 1));
        break;
      case ViewMode.weekly:
        newDate = state.selectedDate.add(const Duration(days: 7));
        break;
      case ViewMode.monthly:
        // Go to next month, same day
        final month = state.selectedDate.month;
        final year = state.selectedDate.year;
        
        if (month == 12) {
          newDate = DateTime(year + 1, 1, state.selectedDate.day);
        } else {
          newDate = DateTime(year, month + 1, state.selectedDate.day);
        }
        break;
    }
    
    context.read<MealPlanBloc>().add(ChangeSelectedDate(newDate));
  }
}

class MealTypeHeader extends StatelessWidget {
  final MealType mealType;
  final int mealCount;
  final VoidCallback onAddPressed;

  const MealTypeHeader({
    Key? key,
    required this.mealType,
    required this.mealCount,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mealColor = _getMealTypeColor(mealType, colorScheme);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: mealColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        color: mealColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          Text(
            mealType.displayName,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          if (mealCount > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mealCount.toString(),
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Only show the add button when meals already exist
          if (mealCount > 0)
            CircleAvatar(
              radius: 20,
              backgroundColor: mealColor.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: onAddPressed,
                color: Colors.white,
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(MealType type, ColorScheme colorScheme) {
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
}

class WeekdaySelector extends StatelessWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeekdaySelector({
    Key? key,
    required this.weekDays,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekDays.map((date) {
        final isSelected = _isSameDay(date, selectedDate);
        final isToday = _isSameDay(date, DateTime.now());
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: InkWell(
                onTap: () => onDateSelected(date),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? colorScheme.primaryContainer 
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.2),
                      width: isToday ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? colorScheme.onPrimaryContainer 
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? colorScheme.primary.withOpacity(0.1) : null,
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? colorScheme.onPrimaryContainer 
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
} 