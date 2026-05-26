import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/habit/data/datasources/habit_local_data_source.dart';
import '../../features/habit/data/datasources/habit_remote_data_source.dart';
import '../../features/habit/domain/repositories/habit_repository.dart';
import '../../features/habit/data/repositories/habit_repository_impl.dart';
import '../../features/habit/presentation/bloc/habit_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencyInjection(
  SharedPreferences sharedPreferences,
) async {
  // Core & External
  await Hive.initFlutter();
  final habitsBox = await Hive.openBox('habits');
  final logsBox = await Hive.openBox('habit_logs');

  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  sl.registerSingleton<Box>(habitsBox, instanceName: 'habitsBox');
  sl.registerSingleton<Box>(logsBox, instanceName: 'logsBox');

  // Features - Auth
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Features - Habit
  // Data Sources
  sl.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(
      habitsBox: sl(instanceName: 'habitsBox'),
      logsBox: sl(instanceName: 'logsBox'),
    ),
  );

  sl.registerLazySingleton<HabitRemoteDataSource>(
    () => HabitRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Blocs
  sl.registerFactory(() => HabitBloc(habitRepository: sl()));
}
