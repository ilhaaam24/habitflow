import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';

void main() {
  group('HabitLogModel Tests', () {
    final testDate = DateTime(2026, 5, 26);

    final testLog = HabitLogModel(
      id: 'log_123',
      habitId: 'habit_456',
      date: testDate,
      isCompleted: true,
      note: 'Finished early!',
    );

    test('should correctly convert to and from JSON', () {
      final jsonMap = testLog.toJson();
      final decodedLog = HabitLogModel.fromJson(jsonMap);

      expect(decodedLog.id, testLog.id);
      expect(decodedLog.habitId, testLog.habitId);
      expect(decodedLog.date, testLog.date);
      expect(decodedLog.isCompleted, testLog.isCompleted);
      expect(decodedLog.note, testLog.note);
    });

    test('should handle nullable note when deserializing', () {
      final logNoNote = HabitLogModel(
        id: 'log_123',
        habitId: 'habit_456',
        date: testDate,
        isCompleted: false,
      );

      final jsonMap = logNoNote.toJson();
      final decodedLog = HabitLogModel.fromJson(jsonMap);

      expect(decodedLog.note, null);
    });
  });
}
