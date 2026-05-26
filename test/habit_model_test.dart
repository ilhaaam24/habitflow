import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/shared/models/habit_model.dart';

void main() {
  group('HabitModel Tests', () {
    final testDate = DateTime(2026, 5, 26, 12, 0, 0);
    const colorInt = 0xFFFF0000; // Red

    final testHabit = HabitModel(
      id: 'habit_123',
      userId: 'user_456',
      title: 'Read Books',
      description: 'Read 10 pages of a book',
      category: 'study',
      icon: '📚',
      colorValue: colorInt,
      reminderTime: '07:30',
      activeDays: ['mon', 'wed', 'fri'],
      createdAt: testDate,
      isActive: true,
    );

    test('should correctly convert to and from JSON', () {
      final jsonMap = testHabit.toJson();
      final decodedHabit = HabitModel.fromJson(jsonMap);

      expect(decodedHabit.id, testHabit.id);
      expect(decodedHabit.userId, testHabit.userId);
      expect(decodedHabit.title, testHabit.title);
      expect(decodedHabit.description, testHabit.description);
      expect(decodedHabit.category, testHabit.category);
      expect(decodedHabit.icon, testHabit.icon);
      expect(decodedHabit.colorValue, testHabit.colorValue);
      expect(decodedHabit.reminderTime, testHabit.reminderTime);
      expect(decodedHabit.activeDays, testHabit.activeDays);
      expect(decodedHabit.createdAt, testHabit.createdAt);
      expect(decodedHabit.isActive, testHabit.isActive);
    });

    test('should return correct Color from colorValue', () {
      expect(testHabit.color, const Color(colorInt));
    });

    test('should return correct TimeOfDay from reminderTime string', () {
      expect(testHabit.reminderTimeOfDay, const TimeOfDay(hour: 7, minute: 30));
    });

    test('should return fallback TimeOfDay for invalid reminderTime string', () {
      final invalidHabit = HabitModel(
        id: 'habit_123',
        userId: 'user_456',
        title: 'Read Books',
        description: '',
        category: 'study',
        icon: '📚',
        colorValue: colorInt,
        reminderTime: 'invalid_time',
        activeDays: ['mon'],
        createdAt: testDate,
      );

      expect(invalidHabit.reminderTimeOfDay, const TimeOfDay(hour: 8, minute: 0));
    });
  });
}
