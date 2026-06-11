import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import 'package:habit_flow/core/navigation/navigation_cubit.dart';
import '../../core/theme/app_colors.dart';

class MainLayout extends StatelessWidget {
  final Widget? child;
  final String? location;
  final StatefulNavigationShell? navigationShell;

  const MainLayout({
    super.key,
    this.child,
    this.location,
    this.navigationShell,
  }) : assert(navigationShell != null || (child != null && location != null));

  NavigationCubit? _getNavigationCubit(BuildContext context) {
    try {
      return context.read<NavigationCubit>();
    } catch (_) {
      return null;
    }
  }

  int _getCurrentNavIndex(BuildContext context) {
    if (navigationShell != null) {
      return navigationShell!.currentIndex;
    }
    final loc = location ?? '';
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/stats')) return 1;
    if (loc.startsWith('/ai-insights')) return 2;
    if (loc.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentNavIndex(context);
    final navCubit = _getNavigationCubit(context);

    // Sync current index state to NavigationCubit
    if (navCubit != null) {
      if (navigationShell != null) {
        final shellIndex = navigationShell!.currentIndex;
        if (navCubit.state != shellIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              navCubit.setTab(shellIndex);
            }
          });
        }
      } else {
        // In widget tests / fallback, sync location-based index
        if (navCubit.state != currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              navCubit.setTab(currentIndex);
            }
          });
        }
      }
    }

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeState) {
        return Scaffold(
          body: Stack(
            children: [
              // Main screen body
              navigationShell ?? child!,
              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: navCubit != null
                      ? BlocBuilder<NavigationCubit, int>(
                          builder: (context, activeIndex) {
                            return _buildNavBarContainer(context, themeState, activeIndex);
                          },
                        )
                      : _buildNavBarContainer(context, themeState, currentIndex),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavBarContainer(
    BuildContext context,
    ThemeMode themeState,
    int activeIndex,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 6,
      ),
      height: 72,
      decoration: BoxDecoration(
        color: themeState == ThemeMode.dark
            ? AppColors.darkBottomAppbar
            : AppColors.bottomAppbar,
      ),
      child: Row(
        spacing: 4,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            currentIndex: activeIndex,
            icon: Icons.home,
            label: 'HOME',
            route: '/home',
          ),
          _buildNavItem(
            context: context,
            index: 1,
            currentIndex: activeIndex,
            icon: Icons.bar_chart,
            label: 'STATS',
            route: '/stats',
          ),
          _buildNavItem(
            context: context,
            index: 2,
            currentIndex: activeIndex,
            icon: Icons.psychology,
            label: 'AI',
            route: '/ai-insights',
          ),
          _buildNavItem(
            context: context,
            index: 3,
            currentIndex: activeIndex,
            icon: Icons.settings,
            label: 'SETTINGS',
            route: '/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final borderColor = AppColors.borderOf(context);
    final selectedBg = AppColors.accentYellowOf(context);
    final unselectedColor = AppColors.accentBrownOf(context);
    final selectedTextColor = AppColors.textOf(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          final navCubit = _getNavigationCubit(context);
          if (navCubit != null) {
            navCubit.setTab(index);
          }
          if (navigationShell != null) {
            navigationShell!.goBranch(
              index,
              initialLocation: index == navigationShell!.currentIndex,
            );
          } else {
            if (currentIndex != index) {
              context.go(route);
            }
          }
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: borderColor, width: 2)
                : null,
            color: isSelected ? selectedBg : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedTextColor : unselectedColor,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1,
                  color: isSelected ? selectedTextColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
