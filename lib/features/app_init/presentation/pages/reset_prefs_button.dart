import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPrefsButton extends StatelessWidget {
  const ResetPrefsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('app_initialized', false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences reset. Restart the app to see onboarding.'),
            ),
          );
        }
      },
      child: const Icon(Icons.refresh),
    );
  }
} 