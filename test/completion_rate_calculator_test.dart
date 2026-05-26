import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';
import 'package:habit_flow/core/helpers/completion_rate_calculator.dart';

void main() {
  group('CompletionRateCalculator Tests', () {
    final today = DateTime(2026, 5, 26); // Tuesday

    test('Zero State: no active days returns 100%', () {
      final habit = HabitModel(
        id: 'h1',
        userId: 'u1',
        title: 'No Active Days Habit',
        description: 'Test',
        category: 'Fitness',
        icon: '💪',
        colorValue: 0,
        activeDays: const [], // No active days scheduled
        reminderTime: '08:00',
        createdAt: today.subtract(const Duration(days: 5)),
      );

      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: [],
        days: 7,
        todayOverride: today,
      );

      expect(rate, equals(100));
    });

    test('7-Day Period: calculates correct consistency percentage', () {
      // Habit active on mon, wed, fri
      final habit = HabitModel(
        id: 'h1',
        userId: 'u1',
        title: 'Weekly Fitness Habit',
        description: 'Test',
        category: 'Fitness',
        icon: '💪',
        colorValue: 0,
        activeDays: const ['mon', 'wed', 'fri'],
        reminderTime: '08:00',
        createdAt: today.subtract(const Duration(days: 10)),
      );

      // Range: [today - 6 days, today] = [Wed May 20, Tue May 26]
      // Active days: Wed May 20, Fri May 22, Mon May 25 (3 active days)
      // Completed: Mon May 25 (1 completion)
      final logs = [
        HabitLogModel(
          id: 'log1',
          habitId: 'h1',
          date: DateTime(2026, 5, 25), // Monday
          isCompleted: true,
        ),
      ];

      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: logs,
        days: 7,
        todayOverride: today,
      );

      // (1 / 3) * 100 = 33%
      expect(rate, equals(33));
    });

    test('30-Day Period: bounds calculation range correctly', () {
      // Habit active daily, created 10 days ago.
      // So total active days in last 30 days is only from creation date (11 active days total including today).
      final habit = HabitModel(
        id: 'h2',
        userId: 'u1',
        title: 'Daily Health Habit',
        description: 'Test',
        category: 'Health',
        icon: '🍎',
        colorValue: 0,
        activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        reminderTime: '08:00',
        createdAt: today.subtract(const Duration(days: 10)), // Created 10 days ago (stripped: May 16)
      );

      // We complete 8 of these 11 days
      final logs = List.generate(8, (index) {
        return HabitLogModel(
          id: 'log_$index',
          habitId: 'h2',
          date: today.subtract(Duration(days: index)),
          isCompleted: true,
        );
      });

      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: logs,
        days: 30,
        todayOverride: today,
      );

      // (8 / 11) * 100 = 73%
      expect(rate, equals(73));
    });

    test('All Time: calculates rate from creation date without period bound', () {
      final habit = HabitModel(
        id: 'h3',
        userId: 'u1',
        title: 'All Time Learning Habit',
        description: 'Test',
        category: 'Learning',
        icon: '📚',
        colorValue: 0,
        activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        reminderTime: '08:00',
        createdAt: today.subtract(const Duration(days: 4)), // May 22 (5 active days: 22, 23, 24, 25, 26)
      );

      final logs = [
        HabitLogModel(id: 'log1', habitId: 'h3', date: today.subtract(const Duration(days: 1)), isCompleted: true), // Completed 1
        HabitLogModel(id: 'log2', habitId: 'h3', date: today.subtract(const Duration(days: 2)), isCompleted: true), // Completed 2
      ];

      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: logs,
        days: null, // All Time
        todayOverride: today,
      );

      // (2 / 5) * 100 = 40%
      expect(rate, equals(40));
    });

    test('calculateMultiple: calculates correctly for multiple habits', () {
      final habit1 = HabitModel(
        id: 'h1',
        userId: 'u1',
        title: 'Habit 1',
        description: 'Test',
        category: 'Fitness',
        icon: '💪',
        colorValue: 0,
        activeDays: const ['mon', 'wed', 'fri'],
        reminderTime: '08:00',
        createdAt: today.subtract(const Duration(days: 10)),
      ); // 3 active days in last 7 days

      final habit2 = HabitModel(
        id: 'h2',
        userId: 'u1',
        title: 'Habit 2',
        description: 'Test',
        category: 'Health',
        icon: '🍎',
        colorValue: 0,
        activeDays: const ['tue', 'thu'],
        reminderTime: '08:00',
        createdAt: today.subtract(const Duration(days: 10)),
      ); // 2 active days in last 7 days (Thu May 21, Tue May 26)

      final logsMap = {
        'h1': [
          HabitLogModel(id: 'log_h1', habitId: 'h1', date: today.subtract(const Duration(days: 1)), isCompleted: true), // Monday May 25 (completed)
        ],
        'h2': [
          HabitLogModel(id: 'log_h2', habitId: 'h2', date: today, isCompleted: true), // Tuesday May 26 (completed)
        ],
      };

      final rate = CompletionRateCalculator.calculateMultiple(
        habits: [habit1, habit2],
        habitsLogs: logsMap,
        days: 7,
        todayOverride: today,
      );

      // Total active days = 3 + 2 = 5
      // Total completed = 1 + 1 = 2
      // (2 / 5) * 100 = 40%
      expect(rate, equals(40));
    });
  });
}
