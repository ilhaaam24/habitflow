import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  int _currentNavIndex = 0; // 0: Home, 1: Stats, 2: AI, 3: Settings

  // Local helper for dummy data when no habits exist
  final List<Map<String, dynamic>> _dummyHabits = [
    {
      'id': 'dummy_1',
      'title': 'MORNING HYDRATION',
      'emoji': '💧',
      'color': 0xFF4D96FF,
      'streak': 12,
      'isCompleted': true,
      'category': '💧 HEALTH',
    },
    {
      'id': 'dummy_2',
      'title': 'EVENING RUN',
      'emoji': '🏃',
      'color': 0xFFFF6B6B,
      'streak': 7,
      'isCompleted': false,
      'category': '🏃 FITNESS',
    },
    {
      'id': 'dummy_3',
      'title': 'READ 20 PAGES',
      'emoji': '📚',
      'color': 0xFFC77DFF,
      'streak': 3,
      'isCompleted': false,
      'category': '📚 LEARNING',
    },
  ];

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
      return const Scaffold(
        backgroundColor: Color(0xFFFFFEF0),
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFEF0),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // TOP BAR
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
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
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 2,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'GOOD MORNING\n${displayName.split(" ").first} 👋'
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.black,
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
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(3, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                child: photoUrl != null
                                    ? Image.network(photoUrl, fit: BoxFit.cover)
                                    : Center(
                                        child: Text(
                                          displayName.isNotEmpty
                                              ? displayName[0]
                                              : 'U',
                                          style: const TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black,
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
                                  color: const Color(0xFF6BCB77),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
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
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayLabel,
                                  style: const TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? const Color(0xFFFFD93D)
                                        : Colors.white,
                                    boxShadow: isToday
                                        ? const [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(3, 3),
                                              blurRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayDate.day.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: Colors.black,
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

                        bool useDummy = false;
                        if (state is HabitLoaded) {
                          habitsList = state.habits;
                          todayLogs = state.todayLogs;
                          if (habitsList.isEmpty) {
                            useDummy = true;
                          }
                        } else if (state is HabitLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          );
                        } else {
                          useDummy = true;
                        }

                        // Calculate scores
                        int completedCount = 0;
                        int totalCount = 0;

                        if (useDummy) {
                          totalCount = _dummyHabits.length;
                          completedCount = _dummyHabits
                              .where((h) => h['isCompleted'] as bool)
                              .length;
                        } else {
                          totalCount = habitsList.length;
                          completedCount = todayLogs
                              .where((log) => log.isCompleted)
                              .length;
                        }

                        final double progressPercent = totalCount > 0
                            ? (completedCount / totalCount)
                            : 0.0;
                        final String progressText =
                            '${(progressPercent * 100).toInt()}%';

                        // Streak calculations: simple mock 23, or max of current habits
                        int maxStreak = 0;
                        if (useDummy) {
                          maxStreak = 23; // Default dummy streak
                        } else {
                          // Simple fallback for streak calculation: mock or calculate from logs
                          maxStreak = totalCount > 0 ? 15 : 0;
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
                                  color: AppColors.accentYellow,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(6, 6),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "TODAY'S SCORE",
                                            style: TextStyle(
                                              fontFamily: 'SpaceGrotesk',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              letterSpacing: 2,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                completedCount.toString(),
                                                style: const TextStyle(
                                                  fontFamily: 'Syne',
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 64,
                                                  height: 1.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '/$totalCount',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'SpaceGrotesk',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24,
                                                      height: 1.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'done',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SpaceGrotesk',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 14,
                                                      height: 1.0,
                                                      color: Colors.black,
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
                                                  Container(
                                                    width: maxWidth,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: progressPercent > 0
                                                        ? AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      300,
                                                                ),
                                                            width:
                                                                maxWidth *
                                                                progressPercent,
                                                            height:
                                                                double.infinity,
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                          )
                                                        : const SizedBox.shrink(),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    progressText,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'SpaceGrotesk',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Colors.black,
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
                                        const Text(
                                          'STREAK',
                                          style: TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            letterSpacing: 2,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 3,
                                            ),

                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(4, 4),
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
                                                maxStreak.toString(),
                                                style: const TextStyle(
                                                  fontFamily: 'SpaceGrotesk',
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  height: 1.0,
                                                ),
                                              ),
                                              const Text(
                                                'DAYS',
                                                style: TextStyle(
                                                  fontFamily: 'SpaceGrotesk',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  letterSpacing: 1,
                                                  color: Colors.black,
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
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.black,
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
                                    const Text(
                                      'MY HABITS',
                                      style: TextStyle(
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      child: const Text(
                                        'SEE ALL →',
                                        style: TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 1,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // HABITS LIST
                              if (useDummy)
                                ..._dummyHabits.map((dummy) {
                                  final String hId = dummy['id'] as String;
                                  final String title = dummy['title'] as String;
                                  final String emoji = dummy['emoji'] as String;
                                  final int colorVal = dummy['color'] as int;
                                  final int streak = dummy['streak'] as int;
                                  final bool isDone =
                                      dummy['isCompleted'] as bool;
                                  final String category =
                                      dummy['category'] as String;

                                  return _buildHabitCard(
                                    id: hId,
                                    title: title,
                                    emoji: emoji,
                                    colorVal: colorVal,
                                    streak: streak,
                                    isDone: isDone,
                                    category: category,
                                    onToggle: () {
                                      setState(() {
                                        dummy['isCompleted'] = !isDone;
                                      });
                                    },
                                  );
                                })
                              else
                                ...habitsList.map((habit) {
                                  final isDone = todayLogs.any(
                                    (log) =>
                                        log.habitId == habit.id &&
                                        log.isCompleted,
                                  );

                                  final streak = state is HabitLoaded
                                      ? (state.streaks[habit.id] ?? 0)
                                      : 0;

                                  return _buildHabitCard(
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
                child: NeobrutalistFab(onTap: () => context.push('/habit/add')),
              ),

              // BOTTOM NAVIGATION BAR
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 6,
                  ),
                  height: 72,
                  decoration: BoxDecoration(color: AppColors.bottomAppbar),
                  child: Row(
                    spacing: 4,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home,
                        label: 'HOME',
                        route: '/home',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.bar_chart,
                        label: 'STATS',
                        route: '/stats',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.psychology,
                        label: 'AI',
                        route: '/ai-settings',
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.settings,
                        label: 'SETTINGS',
                        route: '/settings',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard({
    required String id,
    required String title,
    required String emoji,
    required int colorVal,
    required int streak,
    required bool isDone,
    required String category,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push('/habit/detail/$id'),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD93D),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🔥 $streak DAYS',
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFF6BCB77)
                                    : Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isDone ? 'DONE ✓' : category.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF6BCB77) : Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: isDone
                    ? null
                    : const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: isDone
                  ? const Center(
                      child: Text(
                        '✓',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = _currentNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentNavIndex = index;
          });
          context.push(route);
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ]
                : null,
            color: isSelected ? AppColors.accentYellow : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : AppColors.accentBrown,
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
                  color: isSelected ? Colors.black : AppColors.accentBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
              color: const Color(0xFFFFD93D),
              boxShadow: _isPressed
                  ? const []
                  : const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
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
                  decoration: BoxDecoration(color: const Color(0xFFFF6B6B)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 6,
                  ),
                  child: const Text(
                    'NEW!',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
