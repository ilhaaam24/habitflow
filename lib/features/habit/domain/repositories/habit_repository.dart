import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';

abstract class HabitRepository {
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Stream<List<HabitModel>> getHabits(String userId);
  Future<void> logHabit(HabitLogModel log);
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date);
  Future<List<HabitLogModel>> getLogsForHabit(String habitId);
}
