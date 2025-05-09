import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/meal_plan.dart';
import '../bloc/meal_plan_state.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final ViewMode viewMode;
  final ValueChanged<DateTime> onDateChanged;
  
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.viewMode,
    required this.onDateChanged,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animation when widget is built
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Determine the date formats based on view mode
    final String titleText;
    switch (widget.viewMode) {
      case ViewMode.daily:
        titleText = _isSameDay(widget.selectedDate, DateTime.now()) 
            ? 'Today, ${DateFormat('MMMM d').format(widget.selectedDate)}' 
            : DateFormat('EEEE, MMMM d').format(widget.selectedDate);
        break;
      case ViewMode.weekly:
        final startDate = widget.selectedDate;
        final endDate = widget.selectedDate.add(const Duration(days: 6));
        
        if (startDate.month == endDate.month) {
          // Same month format: "May 7-13"
          titleText = '${DateFormat('MMMM').format(startDate)} ${startDate.day}-${endDate.day}';
        } else if (startDate.year == endDate.year) {
          // Different months, same year: "Apr 28-May 4"
          titleText = '${DateFormat('MMM').format(startDate)} ${startDate.day}-${DateFormat('MMM').format(endDate)} ${endDate.day}';
        } else {
          // Different years: "Dec 30-Jan 5"
          titleText = '${DateFormat('MMM').format(startDate)} ${startDate.day}-${DateFormat('MMM').format(endDate)} ${endDate.day}';
        }
        break;
      case ViewMode.monthly:
        titleText = DateFormat('MMMM yyyy').format(widget.selectedDate);
        break;
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: 60, // Slightly taller for better touch target
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface.withOpacity(0.9),
                    colorScheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavigationButton(
                        context,
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _navigateToPreviousDate();
                          _animateTransition();
                        },
                      ),
                      
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showDatePicker(context);
                          },
                          highlightColor: Colors.transparent,
                          splashColor: colorScheme.primary.withOpacity(0.06),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Calendar icon with gradient
                                Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorScheme.primary.withOpacity(0.15),
                                        colorScheme.primary.withOpacity(0.05),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                
                                // Date text with shine effect
                                Text(
                                  titleText,
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    fontSize: 17,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      _buildNavigationButton(
                        context,
                        icon: Icons.arrow_forward_ios_rounded,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _navigateToNextDate();
                          _animateTransition();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _animateTransition() {
    _animationController.reset();
    _animationController.forward();
  }
  
  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: colorScheme.primary.withOpacity(0.06),
        highlightColor: Colors.transparent,
        child: Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
  
  void _navigateToPreviousDate() {
    DateTime newDate;
    
    switch (widget.viewMode) {
      case ViewMode.daily:
        newDate = widget.selectedDate.subtract(const Duration(days: 1));
        break;
      case ViewMode.weekly:
        // Go to previous week's start date
        newDate = widget.selectedDate.subtract(const Duration(days: 7));
        break;
      case ViewMode.monthly:
        // Go to previous month, same day
        final month = widget.selectedDate.month;
        final year = widget.selectedDate.year;
        
        if (month == 1) {
          newDate = DateTime(year - 1, 12, 1);
        } else {
          newDate = DateTime(year, month - 1, 1);
        }
        break;
    }
    
    widget.onDateChanged(newDate);
  }
  
  void _navigateToNextDate() {
    DateTime newDate;
    
    switch (widget.viewMode) {
      case ViewMode.daily:
        newDate = widget.selectedDate.add(const Duration(days: 1));
        break;
      case ViewMode.weekly:
        // Go to next week's start date
        newDate = widget.selectedDate.add(const Duration(days: 7));
        break;
      case ViewMode.monthly:
        // Go to next month, same day
        final month = widget.selectedDate.month;
        final year = widget.selectedDate.year;
        
        if (month == 12) {
          newDate = DateTime(year + 1, 1, 1);
        } else {
          newDate = DateTime(year, month + 1, 1);
        }
        break;
    }
    
    widget.onDateChanged(newDate);
  }
  
  void _showDatePicker(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: colorScheme.primary,
                  onPrimary: colorScheme.onPrimary,
                  surface: colorScheme.surface,
                  onSurface: colorScheme.onSurface,
                ),
            dialogBackgroundColor: colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      // For weekly view, ensure we always start on the first day of the week
      DateTime dateToUse = pickedDate;
      if (widget.viewMode == ViewMode.weekly) {
        // Adjust to start of week (assuming Sunday is first day, adjust as needed)
        final int weekday = pickedDate.weekday;
        dateToUse = pickedDate.subtract(Duration(days: weekday - 1));
      } else if (widget.viewMode == ViewMode.monthly) {
        // Adjust to first day of month
        dateToUse = DateTime(pickedDate.year, pickedDate.month, 1);
      }
      
      widget.onDateChanged(dateToUse);
    }
  }
  
  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
} 