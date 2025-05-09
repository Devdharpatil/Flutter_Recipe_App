import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/network_info.dart';
import '../data/datasources/meal_plan_datasource.dart';
import '../data/repositories/meal_plan_repository_impl.dart';
import '../domain/repositories/meal_plan_repository.dart';
import '../domain/usecases/add_to_meal_plan.dart';
import '../domain/usecases/get_meal_plans.dart';
import '../presentation/bloc/meal_plan_bloc.dart';

final sl = GetIt.instance;

Future<void> initMealPlanning() async {
  // BLoC
  sl.registerFactory(() => MealPlanBloc(
        getMealPlans: sl(),
        addToMealPlan: sl(),
        repository: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetMealPlans(sl()));
  sl.registerLazySingleton(() => AddToMealPlan(sl()));

  // Repository
  sl.registerLazySingleton<MealPlanRepository>(() => MealPlanRepositoryImpl(
        dataSource: sl(),
        networkInfo: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<MealPlanDataSource>(() => MealPlanDataSourceImpl(
        supabaseClient: sl<SupabaseClient>(),
      ));
} 