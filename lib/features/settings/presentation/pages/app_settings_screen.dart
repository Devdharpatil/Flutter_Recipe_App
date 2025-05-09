import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_settings_bloc.dart';

/// A screen for managing app-wide settings like theme
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch app settings when screen loads
    context.read<AppSettingsBloc>().add(const AppSettingsFetched());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        elevation: 0,
      ),
      body: BlocConsumer<AppSettingsBloc, AppSettingsState>(
        listener: (context, state) {
          if (state is AppSettingsError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is AppSettingsLoaded) {
            // Show success message when theme is changed (except on initial load)
            if (state.themeMode != ThemeMode.system) {
              // Get previous state to check if theme has actually changed
              final prevState = context.read<AppSettingsBloc>().state;
              if (prevState is AppSettingsLoaded && prevState.themeMode != state.themeMode) {
                // Show theme updated confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Theme updated to ${_getThemeModeName(state.themeMode)}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AppSettingsLoading;
          
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Get current theme mode
          final currentThemeMode = _getCurrentThemeMode(state);
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Theme section
              Text(
                'Appearance',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Theme mode selection
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Light theme option
                      _buildThemeOption(
                        context: context,
                        title: 'Light',
                        icon: Icons.light_mode_outlined,
                        isSelected: currentThemeMode == ThemeMode.light,
                        onTap: () => _updateTheme(ThemeMode.light),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Dark theme option
                      _buildThemeOption(
                        context: context,
                        title: 'Dark',
                        icon: Icons.dark_mode_outlined,
                        isSelected: currentThemeMode == ThemeMode.dark,
                        onTap: () => _updateTheme(ThemeMode.dark),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // System theme option
                      _buildThemeOption(
                        context: context,
                        title: 'System',
                        icon: Icons.settings_suggest_outlined,
                        isSelected: currentThemeMode == ThemeMode.system,
                        onTap: () => _updateTheme(ThemeMode.system),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Future: Notifications section (placeholder for V2)
              Text(
                'Notifications',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Enable Notifications',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: const Text(
                    'Coming soon in a future update',
                  ),
                  value: false,
                  onChanged: null, // Disabled for now
                  secondary: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  ThemeMode _getCurrentThemeMode(AppSettingsState state) {
    if (state is AppSettingsLoaded) {
      return state.themeMode;
    } else if (state is AppSettingsError && state.themeMode != null) {
      return state.themeMode!;
    }
    return ThemeMode.system;
  }
  
  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.system:
        return 'System Mode';
    }
  }
  
  void _updateTheme(ThemeMode themeMode) {
    context.read<AppSettingsBloc>().add(ThemeChanged(
      themeMode: themeMode,
    ));
  }
} 