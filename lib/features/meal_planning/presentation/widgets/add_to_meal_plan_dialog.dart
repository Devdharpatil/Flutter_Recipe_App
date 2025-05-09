import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/meal_plan.dart';
import '../bloc/meal_plan_bloc.dart';
import '../bloc/meal_plan_event.dart';
import '../bloc/meal_plan_state.dart';

class AddToMealPlanDialog extends StatefulWidget {
  final int recipeId;
  final String recipeTitle;
  final String recipeImage;
  
  const AddToMealPlanDialog({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImage,
  });
  
  @override
  State<AddToMealPlanDialog> createState() => _AddToMealPlanDialogState();
}

class _AddToMealPlanDialogState extends State<AddToMealPlanDialog> {
  late DateTime _selectedDate;
  MealType _selectedMealType = MealType.dinner;
  int _servings = 2;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return BlocListener<MealPlanBloc, MealPlanState>(
      listenWhen: (previous, current) => 
          previous.isAddingToMealPlan != current.isAddingToMealPlan,
      listener: (context, state) {
        if (!state.isAddingToMealPlan && state.lastAddedMealPlan != null) {
          // Success - close the dialog and show a success message
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to ${state.lastAddedMealPlan!.mealType.displayName}'),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (!state.isAddingToMealPlan && state.failure != null) {
          // Error - show error message but keep dialog open
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog title
                Text(
                  'Add to Meal Plan',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Recipe info
                Row(
                  children: [
                    // Recipe image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.network(
                          widget.recipeImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.broken_image,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Recipe title
                    Expanded(
                      child: Text(
                        widget.recipeTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Date selector
                _buildDateSelector(context),
                const SizedBox(height: 24),
                
                // Meal type selector
                _buildMealTypeSelector(context),
                const SizedBox(height: 24),
                
                // Servings selector
                _buildServingsSelector(context),
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _addToMealPlan,
                      icon: const Icon(Icons.check),
                      label: const Text('Add to Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDateSelector(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showDatePicker,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: textTheme.bodyMedium,
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMealTypeSelector(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Type',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: MealType.values.map((mealType) {
              final isSelected = mealType == _selectedMealType;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMealType = mealType;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        mealType.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        mealType.displayName,
                        style: textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildServingsSelector(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servings',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _servings > 1 
                  ? () {
                      setState(() {
                        _servings--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_servings',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              onPressed: _servings < 10 
                  ? () {
                      setState(() {
                        _servings++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  
  void _addToMealPlan() {
    // Dispatch event to bloc
    context.read<MealPlanBloc>().add(
      AddToMealPlan(
        recipeId: widget.recipeId,
        recipeTitle: widget.recipeTitle,
        recipeImage: widget.recipeImage,
        date: _selectedDate,
        mealType: _selectedMealType,
        servings: _servings,
      ),
    );
  }
} 