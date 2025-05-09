import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/filter_options.dart' as filter;
import '../bloc/filter_cubit.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Include and exclude ingredients controllers
  final TextEditingController _includeController = TextEditingController();
  final TextEditingController _excludeController = TextEditingController();
  
  // Time range state
  late double _maxReadyTime;
  
  // Nutrition ranges
  late RangeValues? _calorieRange;
  late RangeValues? _proteinRange;
  late RangeValues? _carbsRange;
  late RangeValues? _fatRange;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize values from current filter state
    final currentFilters = context.read<FilterCubit>().state;
    
    // Set controllers initial values
    _includeController.text = currentFilters.includeIngredients.join(', ');
    _excludeController.text = currentFilters.excludeIngredients.join(', ');
    
    // Initialize ranges
    _maxReadyTime = currentFilters.maxReadyTime?.toDouble() ?? 60;
    
    // Convert custom RangeValues to Flutter RangeValues
    _calorieRange = currentFilters.calorieRange != null 
        ? RangeValues(currentFilters.calorieRange!.start, currentFilters.calorieRange!.end)
        : null;
        
    _proteinRange = currentFilters.proteinRange != null 
        ? RangeValues(currentFilters.proteinRange!.start, currentFilters.proteinRange!.end)
        : null;
        
    _carbsRange = currentFilters.carbsRange != null 
        ? RangeValues(currentFilters.carbsRange!.start, currentFilters.carbsRange!.end)
        : null;
        
    _fatRange = currentFilters.fatRange != null 
        ? RangeValues(currentFilters.fatRange!.start, currentFilters.fatRange!.end)
        : null;
  }
  
  @override
  void dispose() {
    _includeController.dispose();
    _excludeController.dispose();
    super.dispose();
  }
  
  void _onApplyFilters() {
    if (_formKey.currentState?.validate() == true) {
      // Get current state from FilterCubit
      final updatedFilters = context.read<FilterCubit>().state;
      
      // Update FilterOptions in the SearchBloc
      context.read<SearchBloc>().add(UpdateFilterOptions(updatedFilters));
      
      // Pop back to search results
      context.pop();
    }
  }
  
  void _onReset() {
    context.read<FilterCubit>().reset();
    
    // Reset local state
    setState(() {
      _includeController.text = '';
      _excludeController.text = '';
      _maxReadyTime = 60;
      _calorieRange = null;
      _proteinRange = null;
      _carbsRange = null;
      _fatRange = null;
    });
  }
  
  void _updateIncludeIngredients() {
    final ingredientsText = _includeController.text.trim();
    if (ingredientsText.isEmpty) {
      context.read<FilterCubit>().updateIncludeIngredients([]);
      return;
    }
    
    final ingredients = ingredientsText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    context.read<FilterCubit>().updateIncludeIngredients(ingredients);
  }
  
  void _updateExcludeIngredients() {
    final ingredientsText = _excludeController.text.trim();
    if (ingredientsText.isEmpty) {
      context.read<FilterCubit>().updateExcludeIngredients([]);
      return;
    }
    
    final ingredients = ingredientsText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    context.read<FilterCubit>().updateExcludeIngredients(ingredients);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _onReset,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<FilterCubit, filter.FilterOptions>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diet section
                  _buildSectionTitle('Diet'),
                  _buildDietChips(state.diet),
                  
                  const SizedBox(height: 24),
                  
                  // Intolerances section
                  _buildSectionTitle('Intolerances'),
                  _buildIntoleranceChips(state.intolerances),
                  
                  const SizedBox(height: 24),
                  
                  // Cuisines section
                  _buildSectionTitle('Cuisine'),
                  _buildCuisineChips(state.cuisines),
                  
                  const SizedBox(height: 24),
                  
                  // Max Ready Time section
                  _buildSectionTitle('Max Ready Time (mins)'),
                  _buildTimeSlider(state.maxReadyTime),
                  
                  const SizedBox(height: 24),
                  
                  // Nutrition section - Calories
                  _buildSectionTitle('Calories (kcal)'),
                  _buildRangeSlider(
                    values: _calorieRange ?? const RangeValues(0, 1500),
                    min: 0,
                    max: 1500,
                    divisions: 15,
                    onChanged: (values) {
                      setState(() {
                        _calorieRange = values;
                      });
                    },
                    onChangeEnd: (values) {
                      context.read<FilterCubit>().updateCalorieRange(
                            filter.RangeValues(
                              values.start, 
                              values.end,
                            ),
                          );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Nutrition section - Protein
                  _buildSectionTitle('Protein (g)'),
                  _buildRangeSlider(
                    values: _proteinRange ?? const RangeValues(0, 100),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    onChanged: (values) {
                      setState(() {
                        _proteinRange = values;
                      });
                    },
                    onChangeEnd: (values) {
                      context.read<FilterCubit>().updateProteinRange(
                            filter.RangeValues(
                              values.start, 
                              values.end,
                            ),
                          );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Include/Exclude ingredients section
                  _buildSectionTitle('Include Ingredients'),
                  TextFormField(
                    controller: _includeController,
                    decoration: const InputDecoration(
                      hintText: 'Comma separated (e.g., chicken, tomato)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _updateIncludeIngredients(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Exclude Ingredients'),
                  TextFormField(
                    controller: _excludeController,
                    decoration: const InputDecoration(
                      hintText: 'Comma separated (e.g., cilantro, mushrooms)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _updateExcludeIngredients(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onApplyFilters,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDietChips(String? selectedDiet) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filter.FilterOptions.dietOptions.map((diet) {
        final isSelected = selectedDiet == diet;
        return ChoiceChip(
          label: Text(diet),
          selected: isSelected,
          onSelected: (selected) {
            context.read<FilterCubit>().updateDiet(selected ? diet : null);
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildIntoleranceChips(List<String> selectedIntolerances) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filter.FilterOptions.intoleranceOptions.map((intolerance) {
        final isSelected = selectedIntolerances.contains(intolerance);
        return FilterChip(
          label: Text(intolerance),
          selected: isSelected,
          onSelected: (selected) {
            context.read<FilterCubit>().toggleIntolerance(intolerance);
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildCuisineChips(List<String> selectedCuisines) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filter.FilterOptions.cuisineOptions.map((cuisine) {
        final isSelected = selectedCuisines.contains(cuisine);
        return FilterChip(
          label: Text(cuisine),
          selected: isSelected,
          onSelected: (selected) {
            context.read<FilterCubit>().toggleCuisine(cuisine);
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildTimeSlider(int? maxReadyTime) {
    return Column(
      children: [
        Slider(
          value: _maxReadyTime,
          min: 10,
          max: 120,
          divisions: 11,
          label: '${_maxReadyTime.toInt()} min',
          onChanged: (value) {
            setState(() {
              _maxReadyTime = value;
            });
          },
          onChangeEnd: (value) {
            context.read<FilterCubit>().updateMaxReadyTime(value.toInt());
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10 min'),
              Text('${_maxReadyTime.toInt()} min'),
              Text('120 min'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRangeSlider({
    required RangeValues values,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<RangeValues> onChanged,
    required ValueChanged<RangeValues> onChangeEnd,
  }) {
    return Column(
      children: [
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(
            values.start.toInt().toString(),
            values.end.toInt().toString(),
          ),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(min.toInt().toString()),
              Text('${values.start.toInt()} - ${values.end.toInt()}'),
              Text(max.toInt().toString()),
            ],
          ),
        ),
      ],
    );
  }
} 