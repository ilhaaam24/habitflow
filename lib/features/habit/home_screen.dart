import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/helpers/greeting.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import 'package:intl/intl.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';
import 'package:lottie/lottie.dart';
import '../../shared/widgets/neobrutalist_progress_bar.dart';
import '../../shared/widgets/neobrutalist_button.dart';
import 'neobrutalist_habit_card_item.dart';
import '../../core/di/injection.dart';
import '../../core/services/badge_service.dart';
import '../../shared/widgets/badge_unlock_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<HabitBloc>().add(
          LoadHabitsRequested(userId: authState.user.uid, date: _selectedDate),
        );
      }
    });
  }

  void _onDaySelected(DateTime date, String userId) {
    setState(() {
      _selectedDate = date;
    });
    context.read<HabitBloc>().add(
      LoadHabitsRequested(userId: userId, date: date),
    );
  }

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    // Monday is index 1 in Dart, Sunday is 7.
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.textOf(context)),
        ),
      );
    }

    final user = authState.user;
    final String userId = user.uid;
    final String displayName = user.displayName.toUpperCase();
    final String? photoUrl = user.photoUrl;

    final weekDays = _getCurrentWeekDays();
    final todayFormatted = DateFormat(
      'EEEE, MMM d',
    ).format(DateTime.now()).toUpperCase();

    final borderColor = AppColors.borderOf(context);
    final textColor = AppColors.textOf(context);
    final cardBg = AppColors.cardOf(context);
    final accentYellow = AppColors.accentYellowOf(context);
    final accentGreen = AppColors.accentGreenOf(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go('/login');
            }
          },
        ),
        BlocListener<HabitBloc, HabitState>(
          listener: (context, state) async {
            if (state is HabitLoaded) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                final newlyUnlocked = await sl<BadgeService>()
                    .checkAndUnlockBadges(authState.user.uid);
                if (newlyUnlocked.isNotEmpty && context.mounted) {
                  for (final badge in newlyUnlocked) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => BadgeUnlockDialog(badge: badge),
                    );
                  }
                }
              }
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: state == ThemeMode.light
                ? AppColors.background
                : AppColors.darkBackground,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // TOP BAR
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderColor, width: 2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todayFormatted,
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 2,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${getGreeting()}\n${displayName.split(" ").first} 👋'
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    border: Border.all(
                                      color: borderColor,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: borderColor,
                                        offset: const Offset(3, 3),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    child: photoUrl != null
                                        ? Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Center(
                                            child: Text(
                                              displayName.isNotEmpty
                                                  ? displayName[0]
                                                  : 'U',
                                              style: TextStyle(
                                                fontFamily: 'SpaceGrotesk',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: accentGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '3',
                                        style: TextStyle(
                                          color: cardBg,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // DATE STRIP
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderColor, width: 2),
                          ),
                        ),
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final dayDate = weekDays[index];
                            final dayLabel = DateFormat(
                              'EEE',
                            ).format(dayDate).toUpperCase();
                            final isToday =
                                dayDate.day == _selectedDate.day &&
                                dayDate.month == _selectedDate.month &&
                                dayDate.year == _selectedDate.year;

                            return GestureDetector(
                              onTap: () => _onDaySelected(dayDate, userId),
                              child: Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dayLabel,
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        letterSpacing: 1,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? accentYellow
                                            : cardBg,
                                        boxShadow: isToday
                                            ? [
                                                BoxShadow(
                                                  color: borderColor,
                                                  offset: const Offset(3, 3),
                                                  blurRadius: 0,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          dayDate.day.toString(),
                                          style: TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // CONTENT BODY
                      Expanded(
                        child: BlocBuilder<HabitBloc, HabitState>(
                          builder: (context, state) {
                            List<HabitModel> habitsList = [];
                            List<HabitLogModel> todayLogs = [];

                            if (state is HabitLoaded) {
                              habitsList = state.habits;
                              todayLogs = state.todayLogs;
                              if (habitsList.isEmpty) {
                                return _buildEmptyHabitsState();
                              }
                            } else if (state is HabitLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: textColor,
                                ),
                              );
                            }

                            // Calculate scores
                            int completedCount = 0;
                            int totalCount = 0;
                            int overallStreak = 0;

                            totalCount = habitsList.length;
                            completedCount = todayLogs
                                .where((log) => log.isCompleted)
                                .length;
                            final double progressPercent = totalCount > 0
                                ? (completedCount / totalCount)
                                : 0.0;
                            final String progressText =
                                '${(progressPercent * 100).toInt()}%';

                            if (state is HabitLoaded) {
                              overallStreak = state.overallStreak;
                            }

                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // PROGRESS CARD
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: accentYellow,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: borderColor,
                                          offset: const Offset(6, 6),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "TODAY'S SCORE",
                                                style: TextStyle(
                                                  fontFamily: 'SpaceGrotesk',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  letterSpacing: 2,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    completedCount.toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'Syne',
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 64,
                                                      height: 1.0,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '/$totalCount',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'SpaceGrotesk',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 24,
                                                          height: 1.0,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        'done',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'SpaceGrotesk',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 14,
                                                          height: 1.0,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final double maxWidth =
                                                      constraints.maxWidth - 55;
                                                  return Row(
                                                    children: [
                                                      SizedBox(
                                                        width: maxWidth,
                                                        child:
                                                            NeobrutalistProgressBar(
                                                              value:
                                                                  progressPercent,
                                                              height: 12,
                                                              showLoadingText:
                                                                  true,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        progressText,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'SpaceGrotesk',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          children: [
                                            Text(
                                              'STREAK',
                                              style: TextStyle(
                                                fontFamily: 'SpaceGrotesk',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                letterSpacing: 2,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: cardBg,
                                                border: Border.all(
                                                  color: borderColor,
                                                  width: 3,
                                                ),

                                                boxShadow: [
                                                  BoxShadow(
                                                    color: borderColor,
                                                    offset: const Offset(4, 4),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Lottie.asset(
                                                    'assets/animations/fire.json',
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                                  Text(
                                                    overallStreak.toString(),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SpaceGrotesk',
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 20,
                                                      color: textColor,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    'DAYS',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SpaceGrotesk',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                      letterSpacing: 1,
                                                      color: textColor,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // SECTION HEADER
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: borderColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'MY HABITS',
                                          style: TextStyle(
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            letterSpacing: 1,
                                            color: textColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: cardBg,
                                            border: Border.all(
                                              color: borderColor,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: borderColor,
                                                offset: const Offset(2, 2),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'SEE ALL →',
                                            style: TextStyle(
                                              fontFamily: 'SpaceGrotesk',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              letterSpacing: 1,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ...habitsList.map((habit) {
                                    final isDone = todayLogs.any(
                                      (log) =>
                                          log.habitId == habit.id &&
                                          log.isCompleted,
                                    );

                                    final streak = state is HabitLoaded
                                        ? (state.streaks[habit.id] ?? 0)
                                        : 0;

                                    return NeobrutalistHabitCardItem(
                                      id: habit.id,
                                      title: habit.title.toUpperCase(),
                                      emoji: habit.icon,
                                      colorVal: habit.colorValue,
                                      streak: streak,
                                      isDone: isDone,
                                      category: habit.category,
                                      onToggle: () {
                                        context.read<HabitBloc>().add(
                                          ToggleHabitLogRequested(
                                            habitId: habit.id,
                                            date: _selectedDate,
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // FAB Add button with NEW sticker
                  Positioned(
                    bottom: 88,
                    right: 16,
                    child: NeobrutalistFab(
                      onTap: () => context.push('/habit/add'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyHabitsState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative: Large "0" behind everything
          Positioned(
            child: IgnorePointer(
              child: Center(
                child: Text(
                  '0',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 200,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Large illustration container
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D),
                    border: Border.all(color: Colors.black, width: 4),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(8, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Positioned corners: small "+" marks
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 8,
                        left: 8,
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 8,
                        right: 8,
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w900,
                            fontSize: 100,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('📋', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 4),
                            Text(
                              'EMPTY!',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 2,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Info block
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CustomPaint(
                      painter: DashedBorderPainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'NO HABITS YET.',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start by adding your first habit.\nSmall steps, massive results.',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Colors.black,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // ADD FIRST HABIT button
                            NeobrutalistButton(
                              color: const Color(0xFFFFD93D),
                              onTap: () => context.push('/habit/add'),
                              padding: EdgeInsets.zero,
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      '+',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'ADD FIRST HABIT',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(5),
        ),
      );

    double dashWidth = 8.0;
    double dashSpace = 4.0;

    Path dashedPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeobrutalistFab extends StatefulWidget {
  final VoidCallback onTap;
  const NeobrutalistFab({super.key, required this.onTap});

  @override
  State<NeobrutalistFab> createState() => _NeobrutalistFabState();
}

class _NeobrutalistFabState extends State<NeobrutalistFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.translationValues(
              _isPressed ? 5.0 : 0.0,
              _isPressed ? 5.0 : 0.0,
              0.0,
            ),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentYellowOf(context),
              boxShadow: _isPressed
                  ? const []
                  : [
                      BoxShadow(
                        color: AppColors.borderOf(context),
                        offset: const Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOf(context),
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: _isPressed ? -7 : -12,
          right: _isPressed ? -7 : -12,
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.translationValues(
                _isPressed ? 5.0 : 0.0,
                _isPressed ? 5.0 : 0.0,
                0.0,
              ),
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(15 / 360),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.accentRedOf(context)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 6,
                  ),
                  child: Text(
                    'NEW!',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      color: AppColors.cardOf(context),
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
