import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_flow/features/stats/stats_screen.dart';
import 'package:habit_flow/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/shared/models/user_model.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';
import 'package:habit_flow/features/auth/domain/repositories/auth_repository.dart';

class DummyAuthRepository implements AuthRepository {
  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();
  @override
  UserModel? getCurrentUser() => null;
  @override
  Future<UserModel> signInWithGoogle() async => throw UnimplementedError();
  @override
  Future<void> signOut() async {}
}

class FakeAuthBloc extends AuthBloc {
  FakeAuthBloc() : super(authRepository: DummyAuthRepository());

  @override
  AuthState get state => AuthAuthenticated(
    const UserModel(uid: 'u1', email: 'u1@test.com', displayName: 'Rafi Ahmad'),
  );
}

class MockHabitRepository implements HabitRepository {
  @override
  Future<void> addHabit(HabitModel habit) async {}
  @override
  Future<void> updateHabit(HabitModel habit) async {}
  @override
  Future<void> deleteHabit(String id) async {}
  @override
  Stream<List<HabitModel>> getHabits(String userId) => Stream.value([]);
  @override
  Future<void> logHabit(HabitLogModel log) async {}
  @override
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date) async => [];
  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async => [];
  @override
  Future<int> calculateStreak(String habitId) async => 0;
  @override
  Future<int> getLongestStreak(String habitId) async => 0;
}

class FakeHabitBloc extends HabitBloc {
  FakeHabitBloc() : super(habitRepository: MockHabitRepository());

  @override
  void add(HabitEvent event) {}

  @override
  HabitState get state => HabitLoaded(
    habits: const [],
    todayLogs: const [],
    selectedDate: DateTime.now(),
  );
}

class DynamicMockHabitRepository implements HabitRepository {
  final List<HabitModel> habitsList;
  final Map<String, List<HabitLogModel>> logsMap;
  final Map<String, int> longestStreaksMap;

  DynamicMockHabitRepository({
    required this.habitsList,
    required this.logsMap,
    required this.longestStreaksMap,
  });

  @override
  Future<void> addHabit(HabitModel habit) async {}
  @override
  Future<void> updateHabit(HabitModel habit) async {}
  @override
  Future<void> deleteHabit(String id) async {}
  @override
  Stream<List<HabitModel>> getHabits(String userId) => Stream.value(habitsList);
  @override
  Future<void> logHabit(HabitLogModel log) async {}
  @override
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date) async => [];
  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async => logsMap[habitId] ?? [];
  @override
  Future<int> calculateStreak(String habitId) async => 0;
  @override
  Future<int> getLongestStreak(String habitId) async => longestStreaksMap[habitId] ?? 0;
}

void main() {
  final sl = GetIt.instance;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    sl.allowReassignment = true;
    sl.registerSingleton<HabitRepository>(MockHabitRepository());
  });

  testWidgets('StatsScreen renders header, selectors, metrics, chart, rankings, and streak grid in Neobrutalist style', (WidgetTester tester) async {
    // Set a large screen size to prevent sliver virtualization/overflows from hiding widgets off-screen
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();

    // Register MockHabitRepository
    sl.registerSingleton<HabitRepository>(MockHabitRepository());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    // Verify Sticky AppBar / Header elements
    expect(find.text('ANALYTICS'), findsOneWidget);
    expect(find.text('YOUR HABIT REPORT'), findsOneWidget);
    expect(find.text('←'), findsOneWidget);
    expect(find.text('📅'), findsOneWidget);
    expect(find.text('NOV'), findsOneWidget);

    // Verify Period Selector tabs
    expect(find.text('WEEK'), findsOneWidget);
    expect(find.text('MONTH'), findsOneWidget);
    expect(find.text('ALL TIME'), findsOneWidget);

    // Verify Big Numbers Row metrics (Default is WEEK data)
    expect(find.text('CONSISTENCY'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.text('/100'), findsOneWidget);
    expect(find.text('TOP 8% 🏆'), findsOneWidget);

    expect(find.text('BEST STREAK'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('DAYS IN A ROW'), findsOneWidget);
    expect(find.text('🔥'), findsOneWidget);

    // Verify Weekly Bar Chart section
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    // Grid line labels
    expect(find.text('10'), findsAtLeast(1));
    expect(find.text('5'), findsAtLeast(1));
    expect(find.text('0'), findsAtLeast(1));
    // Weekday labels
    for (var day in ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]) {
      expect(find.text(day), findsOneWidget);
    }
    expect(find.byType(BarChart), findsOneWidget);

    // Verify Completion Trend Line Chart section
    expect(find.text('COMPLETION TREND (4 WEEKS)'), findsOneWidget);
    for (var week in ["W1", "W2", "W3", "W4"]) {
      expect(find.text(week), findsOneWidget);
    }
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);

    // Verify Category Donut Chart section
    expect(find.text('CATEGORY BREAKDOWN'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    // Legend items
    expect(find.textContaining('FITNESS'), findsAtLeast(1));
    expect(find.textContaining('HEALTH'), findsAtLeast(1));
    expect(find.textContaining('LEARNING'), findsAtLeast(1));
    expect(find.textContaining('MIND'), findsAtLeast(1));
    // Badges
    expect(find.text('MOST CONSISTENT'), findsOneWidget);
    expect(find.text('NEEDS ATTENTION'), findsOneWidget);

    // Verify Habit Rankings Table
    expect(find.text('HABIT RANKINGS'), findsOneWidget);
    expect(find.text('MORNING HYDRATION'), findsOneWidget);
    expect(find.text('MEDITATION'), findsOneWidget);
    expect(find.text('EVENING RUN'), findsOneWidget);
    expect(find.text('READING'), findsOneWidget);
    expect(find.text('VITAMINS'), findsOneWidget);

    expect(find.text('95%'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('58%'), findsOneWidget);
    expect(find.text('31%'), findsOneWidget);

    // Verify Streak History Grid
    expect(find.text('STREAK HISTORY'), findsOneWidget);
  });

  testWidgets('StatsScreen period tabs update consistency and best streak metrics on tap', (WidgetTester tester) async {
    // Set a large screen size to prevent sliver virtualization/overflows from hiding widgets off-screen
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();

    // Register MockHabitRepository
    sl.registerSingleton<HabitRepository>(MockHabitRepository());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    // Default should be WEEK stats (92 consistency, 7 streak)
    expect(find.text('92'), findsOneWidget);
    expect(find.text('TOP 8% 🏆'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);

    // Tap MONTH tab
    await tester.tap(find.text('MONTH'));
    await tester.pumpAndSettle();

    // Verify MONTH stats (88 consistency, 23 streak)
    expect(find.text('88'), findsOneWidget);
    expect(find.text('TOP 12% 🏆'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);

    // Tap ALL TIME tab
    await tester.tap(find.text('ALL TIME'));
    await tester.pumpAndSettle();

    // Verify ALL TIME stats (84 consistency, 45 streak)
    expect(find.text('84'), findsOneWidget);
    expect(find.text('TOP 15% 🏆'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    // Tap WEEK tab back
    await tester.tap(find.text('WEEK'));
    await tester.pumpAndSettle();

    // Verify back to WEEK stats
    expect(find.text('92'), findsOneWidget);
    expect(find.text('TOP 8% 🏆'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('StatsScreen computes dynamic statistics using database data', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();

    final today = DateTime.now();

    final realHabit = HabitModel(
      id: 'real_h1',
      userId: 'u1',
      title: 'REAL FITNESS HABIT',
      description: 'Test description',
      category: '🏃 FITNESS',
      icon: '💪',
      colorValue: 0xFF4D96FF,
      activeDays: const ['mon', 'wed', 'fri'],
      reminderTime: '08:00',
      createdAt: today.subtract(const Duration(days: 10)),
    );

    final List<HabitLogModel> logsList = [];
    for (int i = 0; i < 7; i++) {
      logsList.add(
        HabitLogModel(
          id: 'log_$i',
          habitId: 'real_h1',
          date: today.subtract(Duration(days: i)),
          isCompleted: true,
        ),
      );
    }

    final dynamicRepo = DynamicMockHabitRepository(
      habitsList: [realHabit],
      logsMap: {
        'real_h1': logsList,
      },
      longestStreaksMap: {
        'real_h1': 8,
      },
    );

    // Re-register the dynamic repository in GetIt
    sl.registerSingleton<HabitRepository>(dynamicRepo);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dynamic statistics are displayed
    // Best streak should be 8 (from longestStreaksMap)
    expect(find.text('8'), findsOneWidget);

    // Consistency rate should be 100%
    expect(find.text('100'), findsOneWidget);

    // Verify habit title from rankings table
    expect(find.text('REAL FITNESS HABIT'), findsOneWidget);
  });
}
