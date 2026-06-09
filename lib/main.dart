import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'core/utils/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  await GoogleSignIn.instance.initialize();
  await initDependencyInjection(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ThemeCubit(sharedPreferences: sl<SharedPreferences>()),
        ),
        BlocProvider(create: (context) => AuthBloc(authRepository: sl())),
        BlocProvider(create: (context) => HabitBloc(habitRepository: sl())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'HabitFlow AI',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
