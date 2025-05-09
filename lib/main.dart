import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/di_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'core/routing/router.dart';
import 'features/app_init/presentation/cubit/app_initialization_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home_discovery/presentation/bloc/home_bloc.dart';
import 'features/home_discovery/presentation/bloc/category_bloc.dart';
import 'features/user_favorites/presentation/bloc/user_favorites_bloc.dart';
import 'features/user_favorites/presentation/bloc/user_favorites_event.dart';
import 'core/utils/debug_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Reset app_initialized flag for testing onboarding
  // IMPORTANT: Comment this line out for production
  await sharedPreferences.setBool('app_initialized', false);

  // Enable this line for header debugging during development
  // enableHeaderDebug();

  // Initialize Supabase - In a production app, these should be environment variables
  await Supabase.initialize(
    url: 'https://dlppfwgixkbaegxxelif.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRscHBmd2dpeGtiYWVneHhlbGlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyMjYxNTcsImV4cCI6MjA2MTgwMjE1N30.sQmW1sIwmfeLgI43mKUHfhGQTvJQ21nDo9lf0roM-Bg',
  );

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add ThemeService as a provider
        ChangeNotifierProvider<ThemeService>.value(
          value: di.getIt<ThemeService>(),
        ),
        // Continue with BlocProviders
        BlocProvider<AppInitializationCubit>(
          create: (context) => di.getIt<AppInitializationCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => di.getIt<AuthBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => di.getIt<HomeBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => di.getIt<CategoryBloc>(),
        ),
        BlocProvider<UserFavoritesBloc>(
          create: (context) => di.getIt<UserFavoritesBloc>()..add(const LoadFavorites()),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
        title: 'Culinary Compass',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
        routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
