import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_data_source.dart';
import '../datasources/habit_remote_data_source.dart';
import '../../../../shared/models/habit_model.dart';
import '../../../../shared/models/habit_log_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> addHabit(HabitModel habit) async {
    await localDataSource.cacheHabit(habit);
    try {
      await remoteDataSource.syncHabit(habit);
    } catch (_) {
      // Offline-first: allow local success even if sync fails
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await localDataSource.cacheHabit(habit);
    try {
      await remoteDataSource.syncHabit(habit);
    } catch (_) {
      // Offline-first: allow local success even if sync fails
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    final habit = localDataSource.getCachedHabit(id);
    if (habit != null) {
      final userId = habit.userId;
      await localDataSource.deleteHabit(id);
      try {
        await remoteDataSource.deleteHabit(userId, id);
      } catch (_) {
        // Offline-first: allow local success even if sync fails
      }
    } else {
      await localDataSource.deleteHabit(id);
    }
  }

  @override
  Stream<List<HabitModel>> getHabits(String userId) {
    _syncRemoteHabits(userId);
    return localDataSource.watchCachedHabits(userId);
  }

  Future<void> _syncRemoteHabits(String userId) async {
    try {
      final remoteHabits = await remoteDataSource.fetchHabits(userId);
      for (final habit in remoteHabits) {
        await localDataSource.cacheHabit(habit);
      }
    } catch (_) {
      // Silent catch
    }
  }

  @override
  Future<void> logHabit(HabitLogModel log) async {
    await localDataSource.cacheHabitLog(log);
    final habit = localDataSource.getCachedHabit(log.habitId);
    if (habit != null) {
      try {
        await remoteDataSource.syncHabitLog(habit.userId, log);
      } catch (_) {
        // Offline-first: allow local success even if sync fails
      }
    }
  }

  @override
  Future<List<HabitLogModel>> getLogsForDate(
    String userId,
    DateTime date,
  ) async {
    _syncRemoteLogs(userId, date);
    return localDataSource.getCachedLogsForDate(userId, date);
  }

  Future<void> _syncRemoteLogs(String userId, DateTime date) async {
    try {
      final remoteLogs = await remoteDataSource.fetchLogsForDate(userId, date);
      for (final log in remoteLogs) {
        await localDataSource.cacheHabitLog(log);
      }
    } catch (_) {
      // Silent catch
    }
  }

  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    return localDataSource.getCachedLogsForHabit(habitId);
  }
}
