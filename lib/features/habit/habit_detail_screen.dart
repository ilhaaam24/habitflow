import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habit_flow/core/di/injection.dart';
import 'package:habit_flow/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';

class StripesPainter extends CustomPainter {
  final Color color;
  final double stripeWidth;
  final double gap;

  StripesPainter({required this.color, this.stripeWidth = 3.0, this.gap = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;

    final double step = stripeWidth + gap;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StripesPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.gap != gap;
  }
}

class StrikethroughPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  StrikethroughPainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant StrikethroughPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: value ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 3),
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
                decoration: BoxDecoration(
                  color: value ? const Color(0xFFFFD93D) : Colors.black,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitDetailScreen extends StatefulWidget {
  final String id;
  final HabitRepository? repository;

  const HabitDetailScreen({super.key, required this.id, this.repository});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late HabitRepository _habitRepository;
  HabitModel? _habit;
  List<HabitLogModel> _logs = [];
  bool _isLoading = true;

  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalCompleted = 0;
  int _successRate = 0;
  bool _isReminderEnabled = true;

  DateTime _focusedDay = DateTime.now();

  final List<Map<String, dynamic>> _dummyHabits = [
    {
      'id': 'dummy_1',
      'title': 'MORNING HYDRATION',
      'emoji': '💧',
      'color': 0xFF4D96FF,
      'streak': 12,
      'isCompleted': true,
      'category': '💧 HEALTH',
      'reminderTime': '07:00',
    },
    {
      'id': 'dummy_2',
      'title': 'EVENING RUN',
      'emoji': '🏃',
      'color': 0xFFFF6B6B,
      'streak': 23,
      'isCompleted': false,
      'category': '🏃 FITNESS',
      'reminderTime': '19:00',
    },
    {
      'id': 'dummy_3',
      'title': 'READ 20 PAGES',
      'emoji': '📚',
      'color': 0xFFC77DFF,
      'streak': 3,
      'isCompleted': false,
      'category': '📚 LEARNING',
      'reminderTime': '21:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _habitRepository = widget.repository ?? sl<HabitRepository>();
    _loadHabitData();
  }

  void _loadHabitData() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.id.startsWith('dummy_')) {
      final dummyData = _dummyHabits.firstWhere(
        (h) => h['id'] == widget.id,
        orElse: () => _dummyHabits[1],
      );

      final dummyHabit = HabitModel(
        id: dummyData['id'] as String,
        userId: 'dummy_user',
        title: dummyData['title'] as String,
        description: 'Mock habit description',
        category: dummyData['category'] as String,
        icon: dummyData['emoji'] as String,
        colorValue: dummyData['color'] as int,
        reminderTime: dummyData['reminderTime'] as String,
        activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        createdAt: DateTime.now().subtract(const Duration(days: 29)),
        isActive: true,
      );

      final mockLogs = _generateMockLogs(dummyHabit);

      setState(() {
        _habit = dummyHabit;
        _logs = mockLogs;
        _isLoading = false;
        _calculateStats();
      });
    } else {
      HabitModel? realHabit;
      final state = context.read<HabitBloc>().state;
      if (state is HabitLoaded) {
        for (final h in state.habits) {
          if (h.id == widget.id) {
            realHabit = h;
            break;
          }
        }
      }

      if (realHabit != null) {
        final habitLogs = await _habitRepository.getLogsForHabit(widget.id);
        setState(() {
          _habit = realHabit;
          _logs = habitLogs;
          _isLoading = false;
          _calculateStats();
        });
      } else {
        final fallbackDummy = HabitModel(
          id: widget.id,
          userId: 'fallback_user',
          title: 'EVENING RUN',
          description: '',
          category: '🏃 FITNESS',
          icon: '🏃',
          colorValue: 0xFFFF6B6B,
          reminderTime: '19:00',
          activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
          createdAt: DateTime.now().subtract(const Duration(days: 29)),
        );
        setState(() {
          _habit = fallbackDummy;
          _logs = _generateMockLogs(fallbackDummy);
          _isLoading = false;
          _calculateStats();
        });
      }
    }
  }

  List<HabitLogModel> _generateMockLogs(HabitModel habit) {
    final List<HabitLogModel> mockLogs = [];
    final today = DateTime.now();
    final todayStripped = _stripTime(today);

    int scheduledCount = 0;
    DateTime current = todayStripped;

    // Go back in time to find 30 scheduled days
    while (scheduledCount < 30) {
      final weekdayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final weekdayStr = weekdayNames[current.weekday - 1];
      final isScheduled = habit.activeDays.contains(weekdayStr);

      if (isScheduled) {
        scheduledCount++;
        // Day 1 is today (or the most recent active day)
        // Day 1 to 23 (going back): Completed
        // Day 24: Missed
        // Day 25 to 28: Completed
        // Day 29 to 30: Missed
        bool isCompleted = false;
        if (scheduledCount <= 23) {
          isCompleted = true;
        } else if (scheduledCount == 24) {
          isCompleted = false;
        } else if (scheduledCount >= 25 && scheduledCount <= 28) {
          isCompleted = true;
        } else {
          isCompleted = false;
        }

        mockLogs.add(
          HabitLogModel(
            id: 'mock_log_${habit.id}_$scheduledCount',
            habitId: habit.id,
            date: current,
            isCompleted: isCompleted,
          ),
        );
      }
      current = current.subtract(const Duration(days: 1));
    }
    return mockLogs;
  }

  void _calculateStats() async {
    if (_habit == null) return;

    if (widget.id.startsWith('dummy_')) {
      final current = _computeCurrentStreak(_habit!, _logs);
      final longest = _computeLongestStreak(_habit!, _logs);
      final total = _logs.where((l) => l.isCompleted).length;

      int activeCount = 0;
      DateTime cur = _stripTime(_habit!.createdAt);
      final today = _stripTime(DateTime.now());

      while (cur.isBefore(today) || cur.isAtSameMomentAs(today)) {
        if (_isDayActive(cur)) {
          activeCount++;
        }
        cur = cur.add(const Duration(days: 1));
      }

      final rate = activeCount > 0
          ? (total / activeCount * 100).round().clamp(0, 100)
          : 100;

      setState(() {
        _currentStreak = current;
        _bestStreak = longest;
        _totalCompleted = total;
        _successRate = rate;
      });
    } else {
      final current = await _habitRepository.calculateStreak(widget.id);
      final longest = await _habitRepository.getLongestStreak(widget.id);
      final total = _logs.where((l) => l.isCompleted).length;

      int activeCount = 0;
      DateTime cur = _stripTime(_habit!.createdAt);
      final today = _stripTime(DateTime.now());

      while (cur.isBefore(today) || cur.isAtSameMomentAs(today)) {
        if (_isDayActive(cur)) {
          activeCount++;
        }
        cur = cur.add(const Duration(days: 1));
      }

      final rate = activeCount > 0
          ? (total / activeCount * 100).round().clamp(0, 100)
          : 100;

      setState(() {
        _currentStreak = current;
        _bestStreak = longest;
        _totalCompleted = total;
        _successRate = rate;
      });
    }
  }

  int _computeCurrentStreak(HabitModel habit, List<HabitLogModel> logs) {
    final completionMap = <String, bool>{};
    for (final log in logs) {
      if (log.isCompleted) {
        final dateKey = _toDateKey(log.date);
        completionMap[dateKey] = true;
      }
    }

    final today = _stripTime(DateTime.now());
    final createdAtStripped = _stripTime(habit.createdAt);

    int streak = 0;
    DateTime current = today;

    while (current.isAfter(createdAtStripped) ||
        current.isAtSameMomentAs(createdAtStripped)) {
      if (_isDayActive(current)) {
        final dateKey = _toDateKey(current);
        final isCompleted = completionMap[dateKey] ?? false;

        if (isCompleted) {
          streak++;
        } else {
          if (current.isAtSameMomentAs(today)) {
            // Today incomplete doesn't break streak yet
          } else {
            break;
          }
        }
      }
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _computeLongestStreak(HabitModel habit, List<HabitLogModel> logs) {
    final completionMap = <String, bool>{};
    for (final log in logs) {
      if (log.isCompleted) {
        final dateKey = _toDateKey(log.date);
        completionMap[dateKey] = true;
      }
    }

    final today = _stripTime(DateTime.now());
    final createdAtStripped = _stripTime(habit.createdAt);

    int longest = 0;
    int currentRun = 0;

    DateTime current = createdAtStripped;
    while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
      if (_isDayActive(current)) {
        final dateKey = _toDateKey(current);
        final isCompleted = completionMap[dateKey] ?? false;

        if (isCompleted) {
          currentRun++;
          if (currentRun > longest) {
            longest = currentRun;
          }
        } else {
          if (current.isAtSameMomentAs(today)) {
            // Today incomplete doesn't break longest streak yet
          } else {
            currentRun = 0;
          }
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return longest;
  }

  String _toDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isDayActive(DateTime date) {
    if (_habit == null) return false;
    final weekdayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final weekdayStr = weekdayNames[date.weekday - 1];
    return _habit!.activeDays.contains(weekdayStr);
  }

  bool _isDateCompleted(DateTime date) {
    return _logs.any(
      (l) =>
          l.isCompleted &&
          l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day,
    );
  }

  void _toggleDateCompletion(DateTime date) async {
    if (_habit == null) return;

    final dateStripped = _stripTime(date);
    final today = _stripTime(DateTime.now());
    if (dateStripped.isAfter(today)) return;

    if (widget.id.startsWith('dummy_')) {
      final existingIndex = _logs.indexWhere(
        (l) =>
            l.date.year == date.year &&
            l.date.month == date.month &&
            l.date.day == date.day,
      );

      setState(() {
        if (existingIndex != -1) {
          final log = _logs[existingIndex];
          _logs[existingIndex] = HabitLogModel(
            id: log.id,
            habitId: log.habitId,
            date: log.date,
            isCompleted: !log.isCompleted,
          );
        } else {
          _logs.add(
            HabitLogModel(
              id: 'mock_log_${_habit!.id}_${DateTime.now().millisecondsSinceEpoch}',
              habitId: _habit!.id,
              date: dateStripped,
              isCompleted: true,
            ),
          );
        }
        _calculateStats();
      });
    } else {
      context.read<HabitBloc>().add(
        ToggleHabitLogRequested(habitId: _habit!.id, date: dateStripped),
      );
    }
  }

  void _deleteHabit() {
    if (_habit == null) return;
    if (_habit!.id.startsWith('dummy_')) {
      context.pop();
    } else {
      context.read<HabitBloc>().add(DeleteHabitRequested(_habit!.id));
      context.pop();
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFEF0),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DELETE HABIT?",
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Are you sure you want to delete this habit? This action cannot be undone.",
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _deleteHabit();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          border: Border.all(color: Colors.black, width: 2),
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatReminderTime(String time24h) {
    final parts = time24h.split(':');
    if (parts.length != 2) return "7:00 PM";
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute = int.tryParse(parts[1]) ?? 0;
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    final suffix = isPm ? 'PM' : 'AM';
    return '$displayHour:$displayMinute $suffix';
  }

  String _formatActiveDays(List<String> activeDays) {
    if (activeDays.length == 7) {
      return "EVERY DAY";
    }
    if (activeDays.isEmpty) {
      return "NO DAYS";
    }
    return activeDays.map((d) => d.toUpperCase()).join(', ');
  }

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  Widget _buildAppBarButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Center(child: Icon(icon, color: Colors.black, size: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _habit == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFEF0),
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final habitColor = Color(_habit!.colorValue);
    final weekDays = _getCurrentWeekDays();
    final weekMonthYearStr = DateFormat(
      'MMM yyyy',
    ).format(weekDays.first).toUpperCase();

    return BlocListener<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitLoaded && !widget.id.startsWith('dummy_')) {
          final updatedHabit = state.habits
              .where((h) => h.id == widget.id)
              .firstOrNull;
          if (updatedHabit != null) {
            _loadHabitLogs(updatedHabit);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFEF0),
        body: SafeArea(
          child: Column(
            children: [
              // Sticky AppBar
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _buildAppBarButton('←', () => context.pop()),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'HABIT DETAIL',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    _buildAppBarIcon(Icons.edit_outlined, () {
                      context.push('/habit/edit/${_habit!.id}');
                    }),
                    const SizedBox(width: 8),
                    _buildAppBarIcon(Icons.more_horiz, () {}),
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ─── HEADER BLOCK ───
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: habitColor,
                          border: const Border(
                            bottom: BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(6, 6),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _habit!.icon,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _habit!.title.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 26,
                                      letterSpacing: -0.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildHeaderTag(
                                        text: _habit!.category.toUpperCase(),
                                        bgColor: Colors.black,
                                        textColor: Colors.white,
                                        borderColor: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildHeaderTag(
                                        text: 'ACTIVE ✓',
                                        bgColor: Colors.white,
                                        textColor: Colors.black,
                                        borderColor: Colors.white,
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

                    // ─── STATS GRID ───
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'CURRENT STREAK',
                                    value: '$_currentStreak',
                                    subtitle: 'DAYS 🔥',
                                    emoji: '🔥',
                                    bgColor: const Color(0xFFFFD93D),
                                    textColor: Colors.black,
                                    labelColor: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'SUCCESS RATE',
                                    value: '$_successRate%',
                                    subtitle: 'OF ACTIVE DAYS',
                                    emoji: '📈',
                                    bgColor: const Color(0xFF4D96FF),
                                    textColor: Colors.white,
                                    labelColor: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'TOTAL COMPLETED',
                                    value: '$_totalCompleted',
                                    subtitle: 'COMPLETIONS',
                                    emoji: '✅',
                                    bgColor: const Color(0xFF6BCB77),
                                    textColor: Colors.black,
                                    labelColor: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'BEST STREAK',
                                    value: '$_bestStreak',
                                    subtitle: 'DAYS 🔥',
                                    emoji: '🏆',
                                    bgColor: const Color(0xFFFF6FC8),
                                    textColor: Colors.black,
                                    labelColor: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── WEEKLY CHART ───
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "THIS WEEK",
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 2,
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
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    weekMonthYearStr,
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
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(5, 5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(7, (index) {
                                  final date = weekDays[index];
                                  final label = [
                                    'M',
                                    'T',
                                    'W',
                                    'T',
                                    'F',
                                    'S',
                                    'S',
                                  ][index];

                                  final today = _stripTime(DateTime.now());
                                  final isFuture = date.isAfter(today);

                                  double height = 8;
                                  Color color = Colors.white;
                                  bool isStriped = false;

                                  if (!isFuture) {
                                    final isScheduled = _isDayActive(date);
                                    if (isScheduled) {
                                      final isDone = _isDateCompleted(date);
                                      if (isDone) {
                                        height = 90;
                                        color = const Color(0xFFFFD93D);
                                      } else {
                                        height = 20;
                                        color = Colors.white;
                                      }
                                    } else {
                                      height = 45;
                                      color = Colors.white;
                                      isStriped = true;
                                    }
                                  }

                                  return _buildChartBar(
                                    label: label,
                                    height: height,
                                    color: color,
                                    isStriped: isStriped,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── MONTHLY CALENDAR ───
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "MONTHLY VIEW",
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 2,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(5, 5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Custom calendar header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCalendarHeaderButton(
                                        "◀",
                                        () => setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month - 1,
                                            1,
                                          );
                                        }),
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMMM yyyy',
                                        ).format(_focusedDay).toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                        ),
                                      ),
                                      _buildCalendarHeaderButton(
                                        "▶",
                                        () => setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month + 1,
                                            1,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Day of week headers Row
                                  Row(
                                    children:
                                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map(
                                          (day) {
                                            return Expanded(
                                              child: Center(
                                                child: Text(
                                                  day,
                                                  style: const TextStyle(
                                                    fontFamily: 'SpaceGrotesk',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    letterSpacing: 2,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(height: 2, color: Colors.black),
                                  const SizedBox(height: 8),
                                  // Table Calendar
                                  TableCalendar(
                                    firstDay: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDay: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                    focusedDay: _focusedDay,
                                    calendarFormat: CalendarFormat.month,
                                    headerVisible: false,
                                    daysOfWeekVisible: false,
                                    rowHeight: 48,
                                    onPageChanged: (focusedDay) {
                                      setState(() {
                                        _focusedDay = focusedDay;
                                      });
                                    },
                                    calendarBuilders: CalendarBuilders(
                                      prioritizedBuilder:
                                          (context, day, focusedDay) {
                                            return _buildCalendarCell(
                                              day,
                                              focusedDay,
                                            );
                                          },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── REMINDER CARD ───
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D96FF),
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(5, 5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  "🔔",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "REMINDER",
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${_formatActiveDays(_habit!.activeDays)} AT ${_formatReminderTime(_habit!.reminderTime)}",
                                    style: const TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            NeobrutalistSwitch(
                              value: _isReminderEnabled,
                              onChanged: (newValue) {
                                setState(() {
                                  _isReminderEnabled = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── DELETE BUTTON ───
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () => _showDeleteConfirmation(context),
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("🗑", style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                "DELETE HABIT",
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTag({
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtitle,
    required String emoji,
    required Color bgColor,
    required Color textColor,
    required Color labelColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 2,
                    color: labelColor,
                  ),
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w900,
              fontSize: 48,
              height: 1.0,
              color: textColor,
            ),
          ),
          Text(
            subtitle.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar({
    required String label,
    required double height,
    required Color color,
    required bool isStriped,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 90,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 28,
            height: height,
            decoration: BoxDecoration(
              color: isStriped ? Colors.white : color,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isStriped
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: CustomPaint(
                      painter: StripesPainter(
                        color: const Color(0x4D000000),
                        stripeWidth: 2,
                        gap: 3,
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeaderButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, DateTime focusedDay) {
    final isOutside = day.month != focusedDay.month;
    final today = DateTime.now();
    final isToday =
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    final isFuture = day.isAfter(today);

    if (isOutside) {
      return const SizedBox.shrink();
    }

    if (isFuture) {
      return Center(
        child: Text(
          day.day.toString(),
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            color: Colors.black26,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }

    if (isToday) {
      return Center(
        child: GestureDetector(
          onTap: () => _toggleDateCompletion(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isCompleted = _isDateCompleted(day);
    if (isCompleted) {
      return Center(
        child: GestureDetector(
          onTap: () => _toggleDateCompletion(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isScheduled = _isDayActive(day);
    if (isScheduled) {
      return Center(
        child: GestureDetector(
          onTap: () => _toggleDateCompletion(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: GestureDetector(
          onTap: () => _toggleDateCompletion(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: StrikethroughPainter(
                      color: const Color(0x80000000),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _loadHabitLogs(HabitModel habit) async {
    final habitLogs = await _habitRepository.getLogsForHabit(habit.id);
    setState(() {
      _habit = habit;
      _logs = habitLogs;
      _calculateStats();
    });
  }
}
