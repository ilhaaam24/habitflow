import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/habit/home_screen.dart';
import '../../features/habit/add_habit_screen.dart';
import '../../features/habit/habit_detail_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/ai_settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/habit/add',
      builder: (context, state) => const AddHabitScreen(),
    ),
    GoRoute(
      path: '/habit/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AddHabitScreen(habitId: id);
      },
    ),
    GoRoute(
      path: '/habit/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return HabitDetailScreen(id: id);
      },
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/ai-settings',
      builder: (context, state) => const AISettingsScreen(),
    ),
  ],
);
