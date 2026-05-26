import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionLabel({
    required BuildContext context,
    required String text,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 2,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Widget child,
    Color? bgColor,
    VoidCallback? onTap,
  }) {
    final themeBg = Theme.of(context).colorScheme.surface;
    final cardWidget = Container(
      decoration: BoxDecoration(
        color: bgColor ?? themeBg,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }
    return cardWidget;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final String displayName = user?.displayName ?? 'USER';
    final String email = user?.email ?? 'user@habitflow.ai';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color subtextColor = onSurfaceColor.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky AppBar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: onSurfaceColor, width: 3),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(color: onSurfaceColor, width: 3),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: onSurfaceColor,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '←',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 2,
                          color: onSurfaceColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // spacer to center title
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: IDENTITY/GENERAL
                    _buildSectionLabel(
                      context: context,
                      text: '01 — GENERAL',
                      bgColor: const Color(0xFFFFD93D),
                    ),
                    const SizedBox(height: 20),

                    // User Profile Card
                    _buildCard(
                      context: context,
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC77DFF),
                              border: Border.all(color: onSurfaceColor, width: 2.5),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: onSurfaceColor,
                                  offset: const Offset(2.5, 2.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dark Mode Toggle Card
                    _buildCard(
                      context: context,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DARK MODE',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Switch between dark and light themes',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeobrutalistSwitch(
                            value: isDark,
                            onChanged: (_) {
                              context.read<ThemeCubit>().toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // SECTION 2: AI INTEGRATIONS
                    _buildSectionLabel(
                      context: context,
                      text: '02 — AI INTEGRATION',
                      bgColor: const Color(0xFFFF6FC8),
                    ),
                    const SizedBox(height: 20),

                    // AI Settings Card
                    _buildCard(
                      context: context,
                      onTap: () => context.push('/ai-settings'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI MOTIVATION SETTINGS',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Configure Gemini API key & custom AI prompts',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: onSurfaceColor, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // SECTION 3: APP INFO
                    _buildSectionLabel(
                      context: context,
                      text: '03 — ABOUT',
                      bgColor: const Color(0xFF6BCB77),
                    ),
                    const SizedBox(height: 20),

                    // App Info Card
                    _buildCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'APP VERSION',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: onSurfaceColor,
                                ),
                              ),
                              Text(
                                '1.0.0 (BETA)',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DEVELOPED BY',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: onSurfaceColor,
                                ),
                              ),
                              Text(
                                'HABITFLOW AI TEAM',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Exit / Back Button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          border: Border.all(color: onSurfaceColor, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: onSurfaceColor,
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            'BACK TO DASHBOARD',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeobrutalistSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeobrutalistSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: value ? onSurfaceColor : Theme.of(context).colorScheme.surface,
          border: Border.all(color: onSurfaceColor, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeIn,
              left: value ? 28 : 2,
              top: 2,
              bottom: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? const Color(0xFFFFD93D) : onSurfaceColor,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: onSurfaceColor, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
