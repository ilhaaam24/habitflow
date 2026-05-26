import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/features/habit/data/datasources/habit_local_data_source.dart';
import 'package:habit_flow/features/habit/data/datasources/habit_remote_data_source.dart';
import 'package:habit_flow/features/habit/data/repositories/habit_repository_impl.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';

class MockHabitRemoteDataSource implements HabitRemoteDataSource {
  final List<HabitModel> remoteHabits = [];
  final List<HabitLogModel> remoteLogs = [];
  bool shouldFail = false;

  @override
  Future<void> syncHabit(HabitModel habit) async {
    if (shouldFail) throw Exception('Firestore Error');
    remoteHabits.removeWhere((h) => h.id == habit.id);
    remoteHabits.add(habit);
  }

  @override
  Future<void> deleteHabit(String userId, String id) async {
    if (shouldFail) throw Exception('Firestore Error');
    remoteHabits.removeWhere((h) => h.id == id);
    remoteLogs.removeWhere((l) => l.habitId == id);
  }

  @override
  Future<void> syncHabitLog(String userId, HabitLogModel log) async {
    if (shouldFail) throw Exception('Firestore Error');
    remoteLogs.removeWhere((l) => l.id == log.id);
    remoteLogs.add(log);
  }

  @override
  Future<List<HabitModel>> fetchHabits(String userId) async {
    if (shouldFail) throw Exception('Firestore Error');
    return remoteHabits.where((h) => h.userId == userId).toList();
  }

  @override
  Future<List<HabitLogModel>> fetchLogsForDate(String userId, DateTime date) async {
    if (shouldFail) throw Exception('Firestore Error');
    return remoteLogs.where((l) =>
        l.date.year == date.year &&
        l.date.month == date.month &&
        l.date.day == date.day).toList();
  }
}

void main() {
  late Directory tempDir;
  late Box habitsBox;
  late Box logsBox;
  late HabitLocalDataSource localDataSource;
  late MockHabitRemoteDataSource remoteDataSource;
  late HabitRepositoryImpl repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_tests');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    habitsBox = await Hive.openBox('habits_test');
    logsBox = await Hive.openBox('logs_test');
    
    localDataSource = HabitLocalDataSourceImpl(
      habitsBox: habitsBox,
      logsBox: logsBox,
    );
    remoteDataSource = MockHabitRemoteDataSource();
    repository = HabitRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  tearDown(() async {
    await habitsBox.clear();
    await logsBox.clear();
    await habitsBox.close();
    await logsBox.close();
  });

  final testHabit = HabitModel(
    id: 'habit_1',
    userId: 'user_123',
    title: 'Workout',
    description: 'Go to the gym',
    category: 'health',
    icon: '🏋️',
    colorValue: 0xFF00FF00,
    reminderTime: '06:00',
    activeDays: ['mon', 'wed', 'fri'],
    createdAt: DateTime(2026, 5, 26),
  );

  final testLog = HabitLogModel(
    id: 'log_1',
    habitId: 'habit_1',
    date: DateTime(2026, 5, 26),
    isCompleted: true,
    note: 'Leg day done!',
  );

  group('HabitRepository & LocalDataSource Integration Tests', () {
    test('should add habit to local cache and sync to remote database', () async {
      await repository.addHabit(testHabit);

      // Verify local cache
      final localHabit = localDataSource.getCachedHabit(testHabit.id);
      expect(localHabit, isNotNull);
      expect(localHabit!.title, testHabit.title);

      // Verify remote mock
      expect(remoteDataSource.remoteHabits.length, 1);
      expect(remoteDataSource.remoteHabits.first.id, testHabit.id);
    });

    test('should succeed adding locally even if remote sync throws error (offline-first)', () async {
      remoteDataSource.shouldFail = true;

      // Should not throw exception
      await repository.addHabit(testHabit);

      // Cache should still hold it
      final localHabit = localDataSource.getCachedHabit(testHabit.id);
      expect(localHabit, isNotNull);
    });

    test('should update habit correctly', () async {
      await repository.addHabit(testHabit);

      final updatedHabit = HabitModel(
        id: testHabit.id,
        userId: testHabit.userId,
        title: 'Workout Updated',
        description: testHabit.description,
        category: testHabit.category,
        icon: testHabit.icon,
        colorValue: testHabit.colorValue,
        reminderTime: testHabit.reminderTime,
        activeDays: testHabit.activeDays,
        createdAt: testHabit.createdAt,
      );

      await repository.updateHabit(updatedHabit);

      expect(localDataSource.getCachedHabit(testHabit.id)!.title, 'Workout Updated');
      expect(remoteDataSource.remoteHabits.first.title, 'Workout Updated');
    });

    test('should delete habit from local and remote, including associated logs', () async {
      await repository.addHabit(testHabit);
      await repository.logHabit(testLog);

      expect(localDataSource.getCachedHabit(testHabit.id), isNotNull);
      expect(localDataSource.getCachedLogsForHabit(testHabit.id).length, 1);

      await repository.deleteHabit(testHabit.id);

      expect(localDataSource.getCachedHabit(testHabit.id), isNull);
      expect(localDataSource.getCachedLogsForHabit(testHabit.id).length, 0);
      expect(remoteDataSource.remoteHabits.length, 0);
    });

    test('should get watch stream of habits and trigger background remote pull', () async {
      // Setup remote habits
      remoteDataSource.remoteHabits.add(testHabit);

      final stream = repository.getHabits('user_123');
      final firstEmission = await stream.first;

      // Verify first emission includes the background-synced habit
      expect(firstEmission.length, 1);
      expect(firstEmission.first.id, testHabit.id);
    });

    test('should log habit progress and query logs for a given date', () async {
      await repository.addHabit(testHabit);
      await repository.logHabit(testLog);

      final logs = await repository.getLogsForDate('user_123', DateTime(2026, 5, 26));

      expect(logs.length, 1);
      expect(logs.first.id, testLog.id);
      expect(logs.first.isCompleted, isTrue);
    });
  });
}
