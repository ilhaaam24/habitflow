import '../../shared/models/habit_model.dart';
import '../../shared/models/habit_log_model.dart';

class CompletionRateCalculator {
  /// Calculates the completion rate as a percentage: (completed days / total active scheduled days) * 100
  /// for a given [habit] and its [logs] within the last [days] period.
  /// If [days] is null, it calculates for "All Time" since the habit's creation.
  static int calculate({
    required HabitModel habit,
    required List<HabitLogModel> logs,
    int? days,
    DateTime? todayOverride,
  }) {
    final today = todayOverride ?? DateTime.now();
    final todayStripped = DateTime(today.year, today.month, today.day);

    DateTime startDate;
    if (days != null) {
      startDate = todayStripped.subtract(Duration(days: days - 1));
    } else {
      startDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    }

    final rangeStart = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    final finalStart = rangeStart.isAfter(startDate) ? rangeStart : startDate;

    final completionMap = <String, bool>{};
    for (final log in logs) {
      if (log.isCompleted) {
        final dateKey = '${log.date.year}-${log.date.month}-${log.date.day}';
        completionMap[dateKey] = true;
      }
    }

    int activeDaysCount = 0;
    int completedCount = 0;

    DateTime current = finalStart;
    while (current.isBefore(todayStripped) || current.isAtSameMomentAs(todayStripped)) {
      if (_isDayActive(habit, current)) {
        activeDaysCount++;
        final dateKey = '${current.year}-${current.month}-${current.day}';
        if (completionMap[dateKey] ?? false) {
          completedCount++;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    if (activeDaysCount == 0) return 100;
    return (completedCount / activeDaysCount * 100).round().clamp(0, 100);
  }

  /// Calculates the completion rate across multiple [habits] and their logs [habitsLogs].
  static int calculateMultiple({
    required List<HabitModel> habits,
    required Map<String, List<HabitLogModel>> habitsLogs,
    int? days,
    DateTime? todayOverride,
  }) {
    if (habits.isEmpty) return 100;

    final today = todayOverride ?? DateTime.now();
    final todayStripped = DateTime(today.year, today.month, today.day);

    DateTime startDate;
    if (days != null) {
      startDate = todayStripped.subtract(Duration(days: days - 1));
    } else {
      // Find oldest habit creation date
      DateTime oldest = todayStripped;
      for (final h in habits) {
        if (h.createdAt.isBefore(oldest)) {
          oldest = h.createdAt;
        }
      }
      startDate = DateTime(oldest.year, oldest.month, oldest.day);
    }

    int totalActiveDays = 0;
    int totalCompletedLogs = 0;

    for (final habit in habits) {
      final logs = habitsLogs[habit.id] ?? [];
      final completionMap = <String, bool>{};
      for (final log in logs) {
        if (log.isCompleted) {
          final dateKey = '${log.date.year}-${log.date.month}-${log.date.day}';
          completionMap[dateKey] = true;
        }
      }

      final rangeStart = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
      final finalStart = rangeStart.isAfter(startDate) ? rangeStart : startDate;

      DateTime current = finalStart;
      int activeDaysCount = 0;
      int completedCount = 0;

      while (current.isBefore(todayStripped) || current.isAtSameMomentAs(todayStripped)) {
        if (_isDayActive(habit, current)) {
          activeDaysCount++;
          final dateKey = '${current.year}-${current.month}-${current.day}';
          if (completionMap[dateKey] ?? false) {
            completedCount++;
          }
        }
        current = current.add(const Duration(days: 1));
      }

      totalActiveDays += activeDaysCount;
      totalCompletedLogs += completedCount;
    }

    if (totalActiveDays == 0) return 100;
    return (totalCompletedLogs / totalActiveDays * 100).round().clamp(0, 100);
  }

  static bool _isDayActive(HabitModel habit, DateTime date) {
    final weekdayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final weekdayStr = weekdayNames[date.weekday - 1];
    return habit.activeDays.contains(weekdayStr);
  }
}
