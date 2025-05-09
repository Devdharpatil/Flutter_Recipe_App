import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/preferences_bloc.dart';

/// A screen for managing dietary preferences and cooking goals
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Selected preferences
  List<String> _selectedDietaryPreferences = [];
  List<String> _selectedCookingGoals = [];
  bool _hasChanges = false;

  // Available options
  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Low-Fat',
    'Low-Sodium',
    'Pescatarian',
  ];

  final List<String> _goalOptions = [
    'Quick & Easy',
    'Budget-Friendly',
    'Healthy',
    'High-Protein',
    'Family-Friendly',
    'Gourmet',
    'Meal Prep',
    'Weight Loss',
    'Comfort Food',
    'Seasonal',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch preferences data when screen loads
    context.read<PreferencesBloc>().add(const PreferencesFetched());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Preferences'),
        elevation: 0,
      ),
      body: BlocConsumer<PreferencesBloc, PreferencesState>(
        listener: (context, state) {
          // Handle state changes
          if (state is PreferencesLoaded) {
            // Update selected preferences if loaded and not already set
            if (!_hasChanges) {
              setState(() {
                _selectedDietaryPreferences = List.from(state.dietaryPreferences);
                _selectedCookingGoals = List.from(state.cookingGoals);
                _hasChanges = false;
              });
            }
          } else if (state is PreferencesError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is PreferencesUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Preferences saved successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              _hasChanges = false;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is PreferencesLoading;
          final isUpdating = state is PreferencesUpdating;
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dietary Preferences section
                    Text(
                      'Dietary Needs',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select any dietary restrictions or preferences',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _dietaryOptions.map((option) {
                        final isSelected = _selectedDietaryPreferences.contains(option);
                        return FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: isLoading || isUpdating
                              ? null
                              : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDietaryPreferences.add(option);
                                    } else {
                                      _selectedDietaryPreferences.remove(option);
                                    }
                                    _hasChanges = true;
                                  });
                                },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Cooking Goals section
                    Text(
                      'Cooking Goals',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What types of recipes are you looking for?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _goalOptions.map((option) {
                        final isSelected = _selectedCookingGoals.contains(option);
                        return FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: isLoading || isUpdating
                              ? null
                              : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCookingGoals.add(option);
                                    } else {
                                      _selectedCookingGoals.remove(option);
                                    }
                                    _hasChanges = true;
                                  });
                                },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading || isUpdating || !_hasChanges
                            ? null
                            : () {
                                context.read<PreferencesBloc>().add(
                                      PreferencesUpdateRequested(
                                        dietaryPreferences: _selectedDietaryPreferences,
                                        cookingGoals: _selectedCookingGoals,
                                      ),
                                    );
                              },
                        child: isUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Preferences'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Loading overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
} 