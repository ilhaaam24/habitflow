import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import '../../core/theme/app_colors.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  int _getCurrentNavIndex() {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/stats')) return 1;
    if (location.startsWith('/ai-insights')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentNavIndex();
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Main screen body
              child,
              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 6,
                    ),
                    height: 72,
                    decoration: BoxDecoration(
                      color: state == ThemeMode.dark
                          ? AppColors.darkBottomAppbar
                          : AppColors.bottomAppbar,
                    ),
                    child: Row(
                      spacing: 4,
                      children: [
                        _buildNavItem(
                          context: context,
                          index: 0,
                          currentIndex: currentIndex,
                          icon: Icons.home,
                          label: 'HOME',
                          route: '/home',
                        ),
                        _buildNavItem(
                          context: context,
                          index: 1,
                          currentIndex: currentIndex,
                          icon: Icons.bar_chart,
                          label: 'STATS',
                          route: '/stats',
                        ),
                        _buildNavItem(
                          context: context,
                          index: 2,
                          currentIndex: currentIndex,
                          icon: Icons.psychology,
                          label: 'AI',
                          route: '/ai-insights',
                        ),
                        _buildNavItem(
                          context: context,
                          index: 3,
                          currentIndex: currentIndex,
                          icon: Icons.settings,
                          label: 'SETTINGS',
                          route: '/settings',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          if (currentIndex != index) {
            context.go(route);
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

