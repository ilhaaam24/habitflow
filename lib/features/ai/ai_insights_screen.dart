import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/gemini_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/habit/domain/repositories/habit_repository.dart';
import '../../shared/models/habit_model.dart';
import '../../shared/models/habit_log_model.dart';
import '../../shared/widgets/neobrutalist_progress_bar.dart';
import '../../core/helpers/completion_rate_calculator.dart';
import 'package:habit_flow/core/theme/app_colors.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final _prefs = GetIt.instance<SharedPreferences>();
  final _habitRepository = GetIt.instance<HabitRepository>();
  final _geminiService = GetIt.instance<GeminiService>();

  bool _isApiKeyActive = false;
  bool _isLoadingMotivation = false;
  bool _isGeneratingSummary = false;
  bool _hasGeneratedSummary = false;

  int _motivationIndex = 0;
  String _motivationText = "";
  String _weeklySummaryText = "";

  // Calculated Smart Insights
  String _productiveDay = "MONDAY";
  String _productiveSub = "94% on mondays";
  String _strongestHabit = "HYDRATION";
  String _strongestSub = "95% rate";
  String _weakestHabit = "VITAMINS";
  String _weakestSub = "Only 31%";
  String _bestRecord = "31 DAYS";
  String _bestRecordSub = "Evening Run";

  final List<String> _offlineQuotes = [
    "YOU'VE BEEN ON A 23-DAY STREAK FOR EVENING RUN. YOU'RE IN THE TOP 15% OF USERS. NOW PUSH THAT READING HABIT FROM 58% TO 70% THIS WEEK.",
    "HYDRATION IS SOLVED, BUT YOUR READING IS EMBARRASSING. 3 DAYS IN A ROW OF ZERO PAGES IS NOT AN ACCIDENT, IT'S A PATTERN. FIX IT TODAY.",
    "YOUR MONDAYS ARE AMAZING (94%), BUT YOUR FRIDAYS CRASH TO 20%. DISCIPLINE DOES NOT TAKE WEEKENDS OFF. WAKE UP AND DO THE WORK.",
  ];

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    _motivationText = _offlineQuotes[_motivationIndex];
    _calculateSmartInsights();
  }

  void _checkApiKey() {
    final key = _prefs.getString('gemini_api_key');
    setState(() {
      _isApiKeyActive = key != null && key.isNotEmpty;
    });
  }

  Future<void> _calculateSmartInsights() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final String userId = authState.user.uid;
    // Get habits from repository
    final habits = await _habitRepository.getHabits(userId).first;
    if (habits.isEmpty) return;

    final Map<String, List<HabitLogModel>> habitsLogs = {};
    for (final habit in habits) {
      try {
        final logs = await _habitRepository.getLogsForHabit(habit.id);
        habitsLogs[habit.id] = logs;
      } catch (_) {
        habitsLogs[habit.id] = [];
      }
    }

    // 1. Calculate Weekday Completion
    final weekdayCompletion = _calculateWeekdayCompletionRates(
      habits,
      habitsLogs,
    );
    String topDay = "MONDAY";
    double topRate = -1.0;
    weekdayCompletion.forEach((day, rate) {
      if (rate > topRate) {
        topRate = rate;
        topDay = day;
      }
    });

    // 2. Strongest Habit
    HabitModel? strongest;
    int maxRate = -1;
    for (final habit in habits) {
      final logs = habitsLogs[habit.id] ?? [];
      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: logs,
        days: 30,
      );
      if (rate > maxRate) {
        maxRate = rate;
        strongest = habit;
      }
    }

    // 3. Needs Work Habit
    HabitModel? weakest;
    int minRate = 101;
    for (final habit in habits) {
      final logs = habitsLogs[habit.id] ?? [];
      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: logs,
        days: 30,
      );
      if (rate < minRate) {
        minRate = rate;
        weakest = habit;
      }
    }

    // 4. Best Record
    int bestStreak = 0;
    String bestStreakHabit = "Evening Run";
    for (final habit in habits) {
      final streak = await _habitRepository.getLongestStreak(habit.id);
      if (streak > bestStreak) {
        bestStreak = streak;
        bestStreakHabit = habit.title;
      }
    }

    if (mounted) {
      setState(() {
        if (topRate > 0) {
          _productiveDay = topDay;
          _productiveSub = "${topRate.round()}% on ${topDay.toLowerCase()}s";
        }
        if (strongest != null && maxRate >= 0) {
          _strongestHabit = strongest.title.toUpperCase();
          _strongestSub = "$maxRate% rate";
        }
        if (weakest != null && minRate <= 100) {
          _weakestHabit = weakest.title.toUpperCase();
          _weakestSub = "Only $minRate%";
        }
        if (bestStreak > 0) {
          _bestRecord = "$bestStreak DAYS";
          _bestRecordSub = bestStreakHabit;
        }
      });
    }
  }

  Map<String, double> _calculateWeekdayCompletionRates(
    List<HabitModel> habits,
    Map<String, List<HabitLogModel>> habitsLogs,
  ) {
    final weekdayNames = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    final Map<int, int> scheduledCount = {};
    final Map<int, int> completedCount = {};

    for (int i = 1; i <= 7; i++) {
      scheduledCount[i] = 0;
      completedCount[i] = 0;
    }

    final today = DateTime.now();
    final todayStripped = DateTime(today.year, today.month, today.day);
    final startDate = todayStripped.subtract(const Duration(days: 30));

    for (final habit in habits) {
      final logs = habitsLogs[habit.id] ?? [];
      final completedDates = logs
          .where((l) => l.isCompleted)
          .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
          .toSet();

      DateTime current = startDate;
      while (current.isBefore(todayStripped) ||
          current.isAtSameMomentAs(todayStripped)) {
        if (habit.createdAt.isBefore(current) ||
            habit.createdAt.isAtSameMomentAs(current)) {
          final weekdayStr = [
            'mon',
            'tue',
            'wed',
            'thu',
            'fri',
            'sat',
            'sun',
          ][current.weekday - 1];
          if (habit.activeDays.contains(weekdayStr)) {
            scheduledCount[current.weekday] =
                (scheduledCount[current.weekday] ?? 0) + 1;
            final currentStripped = DateTime(
              current.year,
              current.month,
              current.day,
            );
            if (completedDates.contains(currentStripped)) {
              completedCount[current.weekday] =
                  (completedCount[current.weekday] ?? 0) + 1;
            }
          }
        }
        current = current.add(const Duration(days: 1));
      }
    }

    final Map<String, double> results = {};
    for (int i = 1; i <= 7; i++) {
      final sched = scheduledCount[i] ?? 0;
      final comp = completedCount[i] ?? 0;
      final rate = sched > 0 ? (comp / sched * 100) : 0.0;
      results[weekdayNames[i - 1]] = rate;
    }

    return results;
  }

  Future<void> _refreshMotivation() async {
    if (!_isApiKeyActive) {
      // Cycle offline quotes
      setState(() {
        _motivationIndex = (_motivationIndex + 1) % _offlineQuotes.length;
        _motivationText = _offlineQuotes[_motivationIndex];
      });
      return;
    }

    setState(() {
      _isLoadingMotivation = true;
    });

    try {
      final quote = await _geminiService.getMotivation(context);
      if (mounted) {
        setState(() {
          _motivationText = quote;
          _isLoadingMotivation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMotivation = false;
          _motivationIndex = (_motivationIndex + 1) % _offlineQuotes.length;
          _motivationText = _offlineQuotes[_motivationIndex];
        });
      }
    }
  }

  Future<void> _generateSummary() async {
    if (!_isApiKeyActive) {
      showDialog(
        context: context,
        builder: (context) => _buildApiKeyRequiredDialog(),
      );
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
    });

    // Simulated progress loader
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final statsData =
          "Most productive: $_productiveDay ($_productiveSub), Strongest: $_strongestHabit ($_strongestSub), Needs Work: $_weakestHabit ($_strongestSub), Streak: $_bestRecord ($_bestRecordSub).";
      final summary = await _geminiService.getInsight(statsData);

      if (mounted) {
        setState(() {
          _weeklySummaryText = summary;
          _isGeneratingSummary = false;
          _hasGeneratedSummary = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weeklySummaryText =
              "GAGAL GENERATE SUMMARY DARI GEMINI. SILAKAN CEK API KEY DAN KONEKSI INTERNET ANDA.";
          _isGeneratingSummary = false;
          _hasGeneratedSummary = true;
        });
      }
    }
  }

  Widget _buildApiKeyRequiredDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dialogBgOf(context),
          border: Border.all(color: AppColors.borderOf(context), width: 4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: AppColors.borderOf(context), offset: const Offset(6, 6)),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🤖", style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              "API KEY REQUIRED",
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.textOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Connect your free Gemini key in AI Settings to unlock this feature.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 14,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cardOf(context),
                        border: Border.all(color: AppColors.borderOf(context), width: 2.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "CANCEL",
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textOf(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/ai-settings');
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accentYellowOf(context),
                        border: Border.all(color: AppColors.borderOf(context), width: 2.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          "SETUP KEY",
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background watermark
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    "🤖",
                    style: TextStyle(
                      fontSize: 200,
                      color: AppColors.textOf(context).withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDailyMotivationCard(),
                        _buildSectionLabel("SMART INSIGHTS"),
                        _buildSmartInsightsGrid(),
                        _buildWeeklySummaryCard(),
                        _buildSectionLabel("RECOMMENDATIONS"),
                        _buildRecommendations(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderOf(context), width: 4)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AI INSIGHTS",
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  letterSpacing: -1,
                  color: AppColors.textOf(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "YOUR BRUTAL TRUTH 🤖",
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 2,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              context.push('/ai-settings').then((_) => _checkApiKey());
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderOf(context), width: 2),
                borderRadius: BorderRadius.circular(6),
                color: _isApiKeyActive
                    ? AppColors.accentPurpleOf(context)
                    : AppColors.accentRedOf(context),
                boxShadow: [
                  BoxShadow(color: AppColors.borderOf(context), offset: const Offset(3, 3)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _isApiKeyActive ? "AI ON ✓" : "AI OFF ✕",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMotivationCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentYellowOf(context),
        border: Border.all(color: AppColors.borderOf(context), width: 4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: AppColors.borderOf(context), offset: const Offset(8, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderOf(context), width: 3)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.borderOf(context),
                    border: Border.all(color: AppColors.borderOf(context), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    "✦ TODAY'S MOTIVATION",
                    style: TextStyle(
                      color: AppColors.backgroundOf(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _isLoadingMotivation ? null : _refreshMotivation,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.cardOf(context),
                      border: Border.all(color: AppColors.borderOf(context), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: _isLoadingMotivation
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOf(context),
                              ),
                            )
                          : Text(
                              "↺",
                              style: TextStyle(
                                color: AppColors.textOf(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _motivationText.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderOf(context), width: 2)),
            ),
            child: Row(
              children: [
                const Text(
                  "— GEMINI AI",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardOf(context),
                    border: Border.all(color: AppColors.borderOf(context), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Text("✨", style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        "POWERED",
                        style: TextStyle(
                          color: AppColors.textOf(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderOf(context), width: 2),
              borderRadius: BorderRadius.circular(4),
              color: AppColors.borderOf(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 3,
                color: AppColors.backgroundOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightsGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  color: AppColors.accentYellowOf(context),
                  emoji: "📅",
                  label: "MOST PRODUCTIVE",
                  value: _productiveDay,
                  subtitle: _productiveSub,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  color: AppColors.accentGreenOf(context),
                  emoji: "💪",
                  label: "STRONGEST HABIT",
                  value: _strongestHabit,
                  subtitle: _strongestSub,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  color: AppColors.accentRedOf(context),
                  emoji: "⚠️",
                  label: "NEEDS WORK",
                  value: _weakestHabit,
                  subtitle: _weakestSub,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  color: AppColors.accentBlueOf(context),
                  emoji: "🏆",
                  label: "BEST RECORD",
                  value: _bestRecord,
                  subtitle: _bestRecordSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required Color color,
    required String emoji,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.borderOf(context), width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: AppColors.borderOf(context), offset: const Offset(5, 5))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cardOf(context),
                  border: Border.all(color: AppColors.borderOf(context), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const Spacer(),
              const Text(
                "→",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        border: Border.all(color: AppColors.borderOf(context), width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: AppColors.borderOf(context), offset: const Offset(5, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderOf(context), width: 2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cardOf(context),
                    border: Border.all(color: AppColors.borderOf(context), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text("🤖", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "WEEKLY SUMMARY",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      color: AppColors.textOf(context),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.borderOf(context),
                    border: Border.all(color: AppColors.borderOf(context), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    "NEW",
                    style: TextStyle(
                      color: AppColors.backgroundOf(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isGeneratingSummary
                ? Column(
                    children: [
                      const NeobrutalistProgressBar(
                        value: 0.7,
                        height: 12,
                        showLoadingText: false,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          "COMPILING TRUTH...",
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textOf(context),
                          ),
                        ),
                      ),
                    ],
                  )
                : _hasGeneratedSummary
                ? Text(
                    _weeklySummaryText,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textOf(context),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WANT YOUR WEEKLY REPORT?",
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textOf(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Let AI analyze your entire week and give you a no-nonsense breakdown.",
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14,
                          color: AppColors.textSecondaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _generateSummary,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.accentPurpleOf(context),
                            border: Border.all(color: AppColors.borderOf(context), width: 3),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.borderOf(context),
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "GENERATE REPORT ✦",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1,
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

  Widget _buildRecommendations() {
    final List<Map<String, dynamic>> recs = [
      {
        "color": AppColors.accentYellowOf(context),
        "tag": "SCHEDULE",
        "title": "TRY EVENING RUN AT 6PM",
        "desc":
            "Your completion drops 40% on late evenings. Shift it earlier for better results.",
      },
      {
        "color": AppColors.accentPurpleOf(context),
        "tag": "ROUTINE",
        "title": "STACK VITAMINS WITH BREAKFAST",
        "desc":
            "You always complete Hydration in the morning but fail Vitamins. Take your vitamins immediately after drinking your morning water.",
      },
    ];

    return Column(
      children: recs.map((rec) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            border: Border.all(color: AppColors.borderOf(context), width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: AppColors.borderOf(context), offset: const Offset(4, 4)),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bookmark accent bar
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: rec['color'] as Color,
                    border: Border(
                      right: BorderSide(color: AppColors.borderOf(context), width: 2),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("💡", style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.accentYellowOf(context),
                                border: Border.all(
                                  color: AppColors.borderOf(context),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                rec['tag'] as String,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          rec['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.3,
                            color: AppColors.textOf(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rec['desc'] as String,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textSecondaryOf(context),
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
      }).toList(),
    );
  }
}
