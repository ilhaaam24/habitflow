import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:habit_flow/shared/models/habit_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('initialize runs and finishes without throwing', () async {
      expect(notificationService.initialize(), completes);
    });

    test('scheduleHabitReminder with active habit runs and finishes without throwing', () async {
      final habit = HabitModel(
        id: 'test_habit_id',
        userId: 'test_user_id',
        title: 'Exercise Daily',
        description: '30 mins of exercise',
        category: 'fitness',
        icon: '🏃',
        colorValue: 0xFFFF5722,
        reminderTime: '18:30',
        activeDays: ['mon', 'wed', 'fri'],
        createdAt: DateTime.now(),
        isActive: true,
      );

      expect(notificationService.scheduleHabitReminder(habit), completes);
    });

    test('scheduleHabitReminder with inactive habit runs and finishes without throwing', () async {
      final habit = HabitModel(
        id: 'test_habit_id',
        userId: 'test_user_id',
        title: 'Exercise Daily',
        description: '30 mins of exercise',
        category: 'fitness',
        icon: '🏃',
        colorValue: 0xFFFF5722,
        reminderTime: '18:30',
        activeDays: ['mon', 'wed', 'fri'],
        createdAt: DateTime.now(),
        isActive: false, // Inactive
      );

      expect(notificationService.scheduleHabitReminder(habit), completes);
    });

    test('cancelHabitReminder finishes without throwing', () async {
      expect(notificationService.cancelHabitReminder('test_habit_id'), completes);
    });

    test('cancelAllReminders finishes without throwing', () async {
      expect(notificationService.cancelAllReminders(), completes);
    });

    test('rescheduleAll with multiple habits finishes without throwing', () async {
      final habit1 = HabitModel(
        id: 'test_habit_1',
        userId: 'test_user_id',
        title: 'Habit 1',
        description: '',
        category: 'fitness',
        icon: '🏃',
        colorValue: 0xFFFF5722,
        reminderTime: '08:00',
        activeDays: ['mon', 'tue'],
        createdAt: DateTime.now(),
        isActive: true,
      );

      final habit2 = HabitModel(
        id: 'test_habit_2',
        userId: 'test_user_id',
        title: 'Habit 2',
        description: '',
        category: 'fitness',
        icon: '🏃',
        colorValue: 0xFFFF5722,
        reminderTime: '09:00',
        activeDays: ['wed'],
        createdAt: DateTime.now(),
        isActive: true,
      );

      expect(notificationService.rescheduleAll([habit1, habit2]), completes);
    });
  });
}
