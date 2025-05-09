import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/profile_provider.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_list_item.dart';
import '../widgets/settings_group.dart';
import '../widgets/logout_button.dart';

/// A beautiful, premium settings hub screen.
/// 
/// This is the main entry point for all settings-related functionality.
class SettingsHubScreen extends StatefulWidget {
  const SettingsHubScreen({super.key});

  @override
  State<SettingsHubScreen> createState() => _SettingsHubScreenState();
}

class _SettingsHubScreenState extends State<SettingsHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handles the logout action
  void _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    ) ?? false;
    
    if (!shouldLogout) return;
    
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/auth_hub');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Shows the help and support dialog
  void _showHelpAndSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpSection(
                  title: 'Frequently Asked Questions',
                  content: 'How do I save a recipe?\n'
                      '- Tap the heart icon on any recipe to save it to your favorites.\n\n'
                      'How do I create a meal plan?\n'
                      '- Navigate to the Meal Plan tab and tap the + button to add recipes.\n\n'
                      'Can I adjust serving sizes?\n'
                      '- Yes, on the recipe detail page you can adjust the number of servings.',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  title: 'Contact Us',
                  content: 'Email: support@culinarycompass.com\n'
                      'Website: www.culinarycompass.com\n'
                      'Hours: Monday-Friday, 9am-5pm EST',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  title: 'Troubleshooting',
                  content: 'If the app is not working properly:\n'
                      '1. Check your internet connection\n'
                      '2. Restart the app\n'
                      '3. Make sure you have the latest version\n'
                      '4. Clear app cache in your device settings',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Culinary Compass'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpSection(
                  title: 'App Version',
                  content: 'Version 1.0.0 (Build 1)',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  title: 'Description',
                  content: 'Culinary Compass is your personal guide to cooking delicious meals. '
                      'Discover recipes, save favorites, plan meals, and customize your cooking experience. '
                      'With a focus on beautiful design and intuitive user experience, we aim to make cooking enjoyable for everyone.',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  title: 'Legal Information',
                  content: '© 2024 Culinary Compass\n\n'
                      'Recipe data provided by Spoonacular API under license\n\n'
                      'This app is for educational purposes only.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Builds a help section with title and content
  Widget _buildHelpSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Update system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final userProfile = profileProvider.userProfile;
        final isLoading = profileProvider.isLoading;
        
        return Scaffold(
          backgroundColor: colorScheme.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // App bar with settings title - consistent with other screens
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 100,
                      backgroundColor: colorScheme.background,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                        title: Text(
                          'Settings',
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Settings content
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile header with user info
                          isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : SettingsHeader(
                                  displayName: userProfile.displayName.isNotEmpty
                                      ? userProfile.displayName
                                      : 'Culinary Explorer',
                                  email: userProfile.email.isNotEmpty
                                      ? userProfile.email
                                      : 'user@example.com',
                                  avatarUrl: userProfile.avatarUrl,
                                  onProfileTap: () {
                                    context.go('/settings/profile');
                                  },
                                ),
                              
                          // Account settings group
                          SettingsGroup(
                            title: 'ACCOUNT',
                            children: [
                              SettingsListItem(
                                leadingIcon: Icons.person_outline_rounded,
                                title: 'Profile',
                                subtitle: 'Update your personal information',
                                onTap: () {
                                  context.go('/settings/profile');
                                },
                              ),
                              SettingsListItem(
                                leadingIcon: Icons.restaurant_rounded,
                                title: 'Dietary Preferences',
                                subtitle: 'Manage your food preferences',
                                onTap: () {
                                  context.go('/settings/preferences');
                                },
                              ),
                            ],
                          ),
                          
                          // App settings group
                          SettingsGroup(
                            title: 'APPLICATION',
                            children: [
                              SettingsListItem(
                                leadingIcon: Icons.settings_rounded,
                                title: 'App Settings',
                                subtitle: 'Theme, notifications, and display options',
                                onTap: () {
                                  context.go('/settings/app');
                                },
                              ),
                              SettingsListItem(
                                leadingIcon: Icons.help_outline_rounded,
                                title: 'Help & Support',
                                subtitle: 'FAQs, contact, and troubleshooting',
                                onTap: () {
                                  _showHelpAndSupportDialog(context);
                                },
                              ),
                              SettingsListItem(
                                leadingIcon: Icons.info_outline_rounded,
                                title: 'About',
                                subtitle: 'App version and legal information',
                                onTap: () {
                                  _showAboutDialog(context);
                                },
                              ),
                            ],
                          ),
                          
                          // Log out button
                          LogoutButton(
                            onLogout: _handleLogout,
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}