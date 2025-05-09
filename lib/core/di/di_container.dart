import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../network/network_info.dart';
import '../theme/theme_service.dart';
import '../../features/app_init/presentation/cubit/app_initialization_cubit.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Home & Discovery feature
import '../../features/home_discovery/data/datasources/recipe_remote_datasource.dart';
import '../../features/home_discovery/data/datasources/favorites_datasource.dart';
import '../../features/home_discovery/data/repositories/recipe_repository_impl.dart';
import '../../features/home_discovery/domain/repositories/recipe_repository.dart';
import '../../features/home_discovery/domain/usecases/get_trending_recipes_usecase.dart';
import '../../features/home_discovery/domain/usecases/get_categories_usecase.dart';
import '../../features/home_discovery/domain/usecases/get_recipes_by_category_usecase.dart';
import '../../features/home_discovery/presentation/bloc/home_bloc.dart';
import '../../features/home_discovery/presentation/bloc/category_bloc.dart';

// Search feature
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/datasources/search_local_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_recipes_usecase.dart';
import '../../features/search/domain/usecases/get_autocomplete_suggestions_usecase.dart';
import '../../features/search/domain/usecases/get_recent_searches_usecase.dart';
import '../../features/search/domain/usecases/save_recent_search_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/search/presentation/bloc/filter_cubit.dart';

// Recipe Detail feature
import '../../features/recipe_detail/data/datasources/recipe_detail_remote_datasource.dart';
import '../../features/recipe_detail/data/datasources/recipe_detail_local_datasource.dart';
import '../../features/recipe_detail/data/repositories/recipe_detail_repository_impl.dart';
import '../../features/recipe_detail/domain/repositories/recipe_detail_repository.dart';
import '../../features/recipe_detail/domain/usecases/get_recipe_detail_usecase.dart';
import '../../features/recipe_detail/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/recipe_detail/domain/usecases/check_favorite_usecase.dart';
import '../../features/recipe_detail/domain/usecases/get_ingredient_substitutes_usecase.dart';
import '../../features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart';

// Cooking Mode feature
import '../../features/cooking_mode/presentation/bloc/cooking_mode_bloc.dart';

// User Favorites feature
import '../../features/user_favorites/data/datasources/user_favorites_data_source.dart';
import '../../features/user_favorites/data/datasources/user_favorites_data_source_impl.dart';
import '../../features/user_favorites/data/repositories/user_favorites_repository_impl.dart';
import '../../features/user_favorites/domain/repositories/user_favorites_repository.dart';
import '../../features/user_favorites/domain/usecases/add_favorite_usecase.dart';
import '../../features/user_favorites/domain/usecases/load_user_favorites_usecase.dart';
import '../../features/user_favorites/domain/usecases/remove_favorite_usecase.dart';
import '../../features/user_favorites/presentation/bloc/user_favorites_bloc.dart';

// Meal Planning feature
import '../../features/meal_planning/di/meal_planning_injection.dart';
import '../../features/meal_planning/presentation/bloc/meal_plan_bloc.dart';
import '../../features/meal_planning/domain/usecases/add_to_meal_plan.dart';
import '../../features/meal_planning/domain/usecases/get_meal_plans.dart';
import '../../features/meal_planning/data/datasources/meal_plan_datasource.dart';
import '../../features/meal_planning/data/repositories/meal_plan_repository_impl.dart';
import '../../features/meal_planning/domain/repositories/meal_plan_repository.dart';

// Settings feature
import '../../features/settings/data/datasources/user_profile_remote_datasource.dart';
import '../../features/settings/data/repositories/user_profile_repository_impl.dart';
import '../../features/settings/domain/repositories/user_profile_repository.dart';
import '../../features/settings/domain/usecases/get_user_profile_usecase.dart';
import '../../features/settings/domain/usecases/update_user_profile_usecase.dart';
import '../../features/settings/domain/usecases/get_user_preferences_usecase.dart';
import '../../features/settings/domain/usecases/update_user_preferences_usecase.dart';
import '../../features/settings/domain/usecases/get_app_settings_usecase.dart';
import '../../features/settings/domain/usecases/update_app_settings_usecase.dart';
import '../../features/settings/presentation/bloc/profile_bloc.dart';
import '../../features/settings/presentation/bloc/preferences_bloc.dart';
import '../../features/settings/presentation/bloc/app_settings_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton(() => http.Client());

  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());

  // Features - App Initialization
  getIt.registerFactory(() => AppInitializationCubit(
        sharedPreferences: getIt(),
        supabaseClient: getIt(),
      ));
      
  // We don't register OnboardingCubit here because it requires a PageController
  // that should be created in the widget tree. It will be created in the onboarding page.

  // Feature: Auth
  // Bloc
  getIt.registerFactory(() => AuthBloc(
        loginUseCase: getIt(),
        signUpUseCase: getIt(),
        resetPasswordUseCase: getIt(),
      ));

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt()));

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabaseClient: getIt(),
    ),
  );
  
  // Feature: Home & Discovery
  // Bloc
  getIt.registerFactory(() => HomeBloc(
        getTrendingRecipesUseCase: getIt(),
        getCategoriesUseCase: getIt(),
      ));
      
  getIt.registerFactory(() => CategoryBloc(
        getRecipesByCategoryUseCase: getIt(),
      ));

  // Use cases
  getIt.registerLazySingleton(() => GetTrendingRecipesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRecipesByCategoryUseCase(getIt()));

  // Repository
  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      remoteDataSource: getIt(),
      favoritesDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<RecipeRemoteDataSource>(
    () => RecipeRemoteDataSourceImpl(
      client: getIt(),
    ),
  );
  
  getIt.registerLazySingleton<FavoritesDataSource>(
    () => FavoritesDataSourceImpl(
      supabaseClient: getIt(),
    ),
  );
  
  // Feature: Search
  // Bloc/Cubit
  getIt.registerFactory(() => SearchBloc(
        searchRecipesUseCase: getIt(),
        getAutocompleteSuggestionsUseCase: getIt(),
        getRecentSearchesUseCase: getIt(),
        saveRecentSearchUseCase: getIt(),
      ));
      
  getIt.registerFactory(() => FilterCubit());

  // Use cases
  getIt.registerLazySingleton(() => SearchRecipesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAutocompleteSuggestionsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRecentSearchesUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveRecentSearchUseCase(getIt()));

  // Repository
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      favoritesDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(
      client: getIt(),
    ),
  );
  
  getIt.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  // Feature: Recipe Detail
  // Bloc
  getIt.registerFactory(() => RecipeDetailBloc(
        getRecipeDetail: getIt<GetRecipeDetailUseCase>(),
        toggleFavorite: getIt<ToggleFavoriteUseCase>(),
      ));
  
  // Use cases
  getIt.registerLazySingleton(() => GetRecipeDetailUseCase(getIt()));
  getIt.registerLazySingleton(() => ToggleFavoriteUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckFavoriteUseCase(getIt()));
  getIt.registerLazySingleton(() => GetIngredientSubstitutesUseCase(getIt()));
  
  // Repository
  getIt.registerLazySingleton<RecipeDetailRepository>(
    () => RecipeDetailRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Data sources
  getIt.registerLazySingleton<RecipeDetailRemoteDataSource>(
    () => RecipeDetailRemoteDataSourceImpl(
      client: getIt(),
    ),
  );
  
  getIt.registerLazySingleton<RecipeDetailLocalDataSource>(
    () => RecipeDetailLocalDataSourceImpl(
      supabaseClient: getIt(),
    ),
  );

  // Feature: Cooking Mode
  getIt.registerFactory(() => CookingModeBloc());
  
  // Feature: User Favorites
  // Bloc
  getIt.registerFactory(() => UserFavoritesBloc(
        loadUserFavoritesUseCase: getIt(),
        addFavoriteUseCase: getIt(),
        removeFavoriteUseCase: getIt(),
      ));
  
  // Use cases
  getIt.registerLazySingleton(() => LoadUserFavoritesUseCase(getIt()));
  getIt.registerLazySingleton(() => AddFavoriteUseCase(getIt()));
  getIt.registerLazySingleton(() => RemoveFavoriteUseCase(getIt()));
  
  // Repository
  getIt.registerLazySingleton<UserFavoritesRepository>(
    () => UserFavoritesRepositoryImpl(
      dataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Data sources
  getIt.registerLazySingleton<UserFavoritesDataSource>(
    () => UserFavoritesDataSourceImpl(
      supabaseClient: getIt(),
    ),
  );
  
  // Feature: Meal Planning
  // Bloc
  getIt.registerFactory(() => MealPlanBloc(
        getMealPlans: getIt<GetMealPlans>(),
        addToMealPlan: getIt<AddToMealPlan>(),
        repository: getIt<MealPlanRepository>(),
      ));
  
  // Use cases  
  getIt.registerLazySingleton(() => GetMealPlans(getIt()));
  getIt.registerLazySingleton(() => AddToMealPlan(getIt()));
  
  // Repository
  getIt.registerLazySingleton<MealPlanRepository>(
    () => MealPlanRepositoryImpl(
      dataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Data sources
  getIt.registerLazySingleton<MealPlanDataSource>(
    () => MealPlanDataSourceImpl(
      supabaseClient: getIt(),
    ),
  );
  
  // Feature: Settings
  // Blocs
  getIt.registerFactory(() => ProfileBloc(
        getUserProfile: getIt(),
        updateUserProfile: getIt(),
      ));
      
  getIt.registerFactory(() => PreferencesBloc(
        getUserPreferences: getIt(),
        updateUserPreferences: getIt(),
      ));
      
  getIt.registerFactory(() => AppSettingsBloc(
        getAppSettings: getIt(),
        updateAppSettings: getIt(),
        themeService: getIt(),
      ));
  
  // Use cases
  getIt.registerLazySingleton(() => GetUserProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUserPreferencesUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserPreferencesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAppSettingsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateAppSettingsUseCase(getIt()));
  
  // Repository
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Data sources
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(
      supabaseClient: getIt(),
    ),
  );
} 