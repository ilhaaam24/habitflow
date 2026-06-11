import 'package:flutter/material.dart';
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
import '../../features/ai/ai_insights_screen.dart';
import '../../shared/widgets/main_layout.dart';

CustomTransitionPage<void> buildPageWithBrutalistTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.linear)),
        ),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => buildPageWithBrutalistTransition(
        context,
        state,
        const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          buildPageWithBrutalistTransition(context, state, const LoginScreen()),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  buildPageWithBrutalistTransition(context, state, const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              pageBuilder: (context, state) =>
                  buildPageWithBrutalistTransition(context, state, const StatsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai-insights',
              pageBuilder: (context, state) => buildPageWithBrutalistTransition(
                context,
                state,
                const AIInsightsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => buildPageWithBrutalistTransition(
                context,
                state,
                const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/habit/add',
      pageBuilder: (context, state) => buildPageWithBrutalistTransition(
        context,
        state,
        const AddHabitScreen(),
      ),
    ),
    GoRoute(
      path: '/habit/edit/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return buildPageWithBrutalistTransition(
          context,
          state,
          AddHabitScreen(habitId: id),
        );
      },
    ),
    GoRoute(
      path: '/habit/detail/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return buildPageWithBrutalistTransition(
          context,
          state,
          HabitDetailScreen(id: id),
        );
      },
    ),
    GoRoute(
      path: '/ai-settings',
      pageBuilder: (context, state) => buildPageWithBrutalistTransition(
        context,
        state,
        const AISettingsScreen(),
      ),
    ),
  ],
);
