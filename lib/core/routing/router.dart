import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../di/di_container.dart';
import '../../features/app_init/presentation/pages/splash_screen.dart';
import '../../features/app_init/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_hub_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/home_discovery/presentation/pages/home_screen.dart';
import '../../features/home_discovery/presentation/pages/enhanced_home_screen.dart';
import '../../features/home_discovery/presentation/pages/categories_screen.dart';
import '../../features/home_discovery/presentation/pages/category_results_screen.dart';
import '../../features/home_discovery/presentation/pages/trending_recipes_screen.dart';
import '../../features/search/presentation/pages/search_input_screen.dart';
import '../../features/search/presentation/pages/filter_screen.dart';
import '../../features/search/presentation/pages/search_results_screen.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/search/presentation/bloc/filter_cubit.dart';
import '../../features/recipe_detail/presentation/pages/recipe_detail_screen.dart';
import '../../features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart';
import '../../features/recipe_detail/domain/usecases/get_recipe_detail_usecase.dart';
import '../../features/cooking_mode/presentation/pages/cooking_mode_screen.dart';
import '../../features/cooking_mode/presentation/bloc/cooking_mode_bloc.dart';
import '../../features/user_favorites/presentation/pages/favorites_screen.dart';
import '../../features/user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../features/user_favorites/presentation/bloc/user_favorites_event.dart';
import '../../features/meal_planning/presentation/pages/compact_meal_plan_screen.dart';
import '../../features/meal_planning/presentation/pages/meal_plan_screen.dart';
import '../../features/meal_planning/presentation/bloc/meal_plan_bloc.dart';
import '../../features/settings/presentation/pages/settings_hub_screen.dart';
import '../../features/settings/presentation/pages/profile_screen.dart';
import '../../features/settings/presentation/pages/preferences_screen.dart';
import '../../features/settings/presentation/pages/app_settings_screen.dart';
import '../../features/settings/presentation/providers/profile_provider.dart';
import '../../features/settings/presentation/bloc/profile_bloc.dart';
import '../../features/settings/presentation/bloc/preferences_bloc.dart';
import '../../features/settings/presentation/bloc/app_settings_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Main app flow
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Get the current route to determine which tab is active
          final currentLocation = state.uri.path;
          int currentIndex = 0;
          
          if (currentLocation.startsWith('/home')) {
            currentIndex = 0;
          } else if (currentLocation == '/search' || 
                    currentLocation == '/search_filter' || 
                    currentLocation.startsWith('/search_results')) {
            currentIndex = 1;
          } else if (currentLocation.startsWith('/favorites')) {
            currentIndex = 2;
          } else if (currentLocation.startsWith('/meal_plan')) {
            currentIndex = 3;
          } else if (currentLocation.startsWith('/settings')) {
            currentIndex = 4;
          }
          
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_outlined),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu),
                  label: 'Meal Plan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/search');
                    break;
                  case 2:
                    context.go('/favorites');
                    break;
                  case 3:
                    context.go('/meal_plan');
                    break;
                  case 4:
                    context.go('/settings');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          // Home route
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EnhancedHomeScreen(),
            ),
          ),
          
          // Categories routes
          GoRoute(
            path: '/categories',
            name: 'categories',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CategoriesScreen(),
            ),
          ),
          GoRoute(
            path: '/category/:name',
            name: 'category_results',
            builder: (context, state) {
              final category = state.pathParameters['name'] ?? '';
              return CategoryResultsScreen(category: category);
            },
          ),
          
          // Trending recipes route
          GoRoute(
            path: '/trending',
            name: 'trending_recipes',
            builder: (context, state) {
              return const TrendingRecipesScreen();
            },
          ),
          
          // Search routes
          GoRoute(
            path: '/search',
            builder: (context, state) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<SearchBloc>(
                    create: (_) => getIt<SearchBloc>(),
                  ),
                  BlocProvider<FilterCubit>(
                    create: (_) => getIt<FilterCubit>(),
                  ),
                ],
                child: const SearchInputScreen(),
              );
            },
          ),
          GoRoute(
            path: '/search_filter',
            builder: (context, state) {
              return BlocProvider<FilterCubit>(
                create: (_) => getIt<FilterCubit>(),
                child: const FilterScreen(),
              );
            },
          ),
          GoRoute(
            path: '/search_results',
            builder: (context, state) {
              final query = state.uri.queryParameters['query'] ?? '';
              return MultiBlocProvider(
                providers: [
                  BlocProvider<SearchBloc>(
                    create: (_) => getIt<SearchBloc>(),
                  ),
                  BlocProvider<FilterCubit>(
                    create: (_) => getIt<FilterCubit>(),
                  ),
                ],
                child: SearchResultsScreen(query: query),
              );
            },
          ),
          
          // Favorites route
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) => NoTransitionPage(
              child: MultiProvider(
                providers: [
                  BlocProvider<UserFavoritesBloc>(
                    create: (_) => getIt<UserFavoritesBloc>(),
                  ),
                  Provider<GetRecipeDetailUseCase>.value(
                    value: getIt<GetRecipeDetailUseCase>(),
                  ),
                ],
                child: const FavoritesScreen(),
              ),
            ),
          ),
          
          // Meal Planning route
          GoRoute(
            path: '/meal_plan',
            pageBuilder: (context, state) => NoTransitionPage(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<MealPlanBloc>(
                    create: (_) => getIt<MealPlanBloc>(),
                  ),
                  BlocProvider<UserFavoritesBloc>(
                    create: (_) => getIt<UserFavoritesBloc>()..add(const LoadFavorites()),
                  ),
                ],
                child: const CompactMealPlanScreen(),
              ),
            ),
          ),
          
          // Settings routes
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ChangeNotifierProvider(
                create: (_) => ProfileProvider(),
                child: const SettingsHubScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => BlocProvider<ProfileBloc>(
                  create: (_) => getIt<ProfileBloc>(),
                  child: const ProfileScreen(),
                ),
              ),
              GoRoute(
                path: 'preferences',
                builder: (context, state) => BlocProvider<PreferencesBloc>(
                  create: (_) => getIt<PreferencesBloc>(),
                  child: const PreferencesScreen(),
                ),
              ),
              GoRoute(
                path: 'app',
                builder: (context, state) => BlocProvider<AppSettingsBloc>(
                  create: (_) => getIt<AppSettingsBloc>(),
                  child: const AppSettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Authentication flow
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sign_up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth_hub',
        builder: (context, state) => const AuthHubScreen(),
      ),

      // Recipe Detail and Cooking Mode (fullscreen experiences)
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) {
          final recipeId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return BlocProvider<RecipeDetailBloc>(
            create: (_) => getIt<RecipeDetailBloc>(),
            child: RecipeDetailScreen(recipeId: recipeId),
          );
        },
      ),
      GoRoute(
        path: '/cooking_mode/:id',
        builder: (context, state) {
          final recipeId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return MultiBlocProvider(
            providers: [
              BlocProvider<RecipeDetailBloc>(
                create: (_) => getIt<RecipeDetailBloc>(),
              ),
              BlocProvider<CookingModeBloc>(
                create: (_) => getIt<CookingModeBloc>(),
              ),
            ],
            child: CookingModeScreen(recipeId: recipeId),
          );
        },
      ),

      // Onboarding & Initialization
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
} 