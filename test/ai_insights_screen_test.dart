import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import 'package:habit_flow/features/ai/ai_insights_screen.dart';
import 'package:habit_flow/core/services/gemini_service.dart';
import 'package:habit_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/shared/models/user_model.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';

// Dummy implementation for AuthRepo
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
  final List<HabitModel> habits;
  final Map<String, List<HabitLogModel>> logs;
  final Map<String, int> streaks;

  MockHabitRepository({
    this.habits = const [],
    this.logs = const {},
    this.streaks = const {},
  });

  @override
  Future<void> addHabit(HabitModel habit) async {}
  @override
  Future<void> updateHabit(HabitModel habit) async {}
  @override
  Future<void> deleteHabit(String id) async {}
  @override
  Stream<List<HabitModel>> getHabits(String userId) => Stream.value(habits);
  @override
  Future<void> logHabit(HabitLogModel log) async {}
  @override
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date) async => [];
  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async => logs[habitId] ?? [];
  @override
  Future<int> calculateStreak(String habitId) async => streaks[habitId] ?? 0;
  @override
  Future<int> getLongestStreak(String habitId) async => streaks[habitId] ?? 0;
}

class FakeHabitBloc extends HabitBloc {
  final List<HabitModel> habits;
  final Map<String, int> streaks;

  FakeHabitBloc({this.habits = const [], this.streaks = const {}})
      : super(habitRepository: MockHabitRepository(habits: habits, streaks: streaks));

  @override
  HabitState get state => HabitLoaded(
        habits: habits,
        todayLogs: const [],
        selectedDate: DateTime.now(),
        streaks: streaks,
      );
}

class MockGeminiService extends Fake implements GeminiService {
  final String motivationResponse;
  final String insightResponse;

  MockGeminiService({
    this.motivationResponse = "GEMINI DYNAMIC MOTIVATION TEXT",
    this.insightResponse = "GEMINI DYNAMIC WEEKLY SUMMARY TEXT",
  });

  @override
  Future<String> getMotivation(BuildContext context) async => motivationResponse;

  @override
  Future<String> getInsight(String habitData) async => insightResponse;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sl = GetIt.instance;
    if (sl.isRegistered<SharedPreferences>()) {
      await sl.unregister<SharedPreferences>();
    }
    if (sl.isRegistered<HabitRepository>()) {
      await sl.unregister<HabitRepository>();
    }
    if (sl.isRegistered<GeminiService>()) {
      await sl.unregister<GeminiService>();
    }

    sl.registerSingleton<SharedPreferences>(prefs);
  });

  testWidgets('AIInsightsScreen renders offline details when key is missing', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final sl = GetIt.instance;
    sl.registerSingleton<HabitRepository>(MockHabitRepository());
    sl.registerSingleton<GeminiService>(MockGeminiService());

    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(
          home: AIInsightsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text('AI INSIGHTS'), findsOneWidget);
    expect(find.text('YOUR BRUTAL TRUTH 🤖'), findsOneWidget);

    // Verify Badge is AI OFF
    expect(find.text('AI OFF ✕'), findsOneWidget);

    // Verify Daily Motivation displays default quote
    expect(find.text("✦ TODAY'S MOTIVATION"), findsOneWidget);
    expect(
      find.text(
        "YOU'VE BEEN ON A 23-DAY STREAK FOR EVENING RUN. YOU'RE IN THE TOP 15% OF USERS. NOW PUSH THAT READING HABIT FROM 58% TO 70% THIS WEEK.",
      ),
      findsOneWidget,
    );

    // Verify 2x2 Grid elements render
    expect(find.text('MOST PRODUCTIVE'), findsOneWidget);
    expect(find.text('STRONGEST HABIT'), findsOneWidget);
    expect(find.text('NEEDS WORK'), findsOneWidget);
    expect(find.text('BEST RECORD'), findsOneWidget);

    // Verify Weekly Summary prompt
    expect(find.text('WEEKLY SUMMARY'), findsOneWidget);
    expect(find.text('WANT YOUR WEEKLY REPORT?'), findsOneWidget);

    // Verify Recommendations cards
    expect(find.text('TRY EVENING RUN AT 6PM'), findsOneWidget);
    expect(find.text('STACK VITAMINS WITH BREAKFAST'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Tapping refresh quote cycles offline quotes when API key is missing', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final sl = GetIt.instance;
    sl.registerSingleton<HabitRepository>(MockHabitRepository());
    sl.registerSingleton<GeminiService>(MockGeminiService());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => FakeAuthBloc()),
          BlocProvider<HabitBloc>(create: (_) => FakeHabitBloc()),
        ],
        child: const MaterialApp(
          home: AIInsightsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find refresh button and tap it
    await tester.tap(find.text('↺'));
    await tester.pumpAndSettle();

    // Motivation should cycle to Quote 2
    expect(
      find.text(
        "HYDRATION IS SOLVED, BUT YOUR READING IS EMBARRASSING. 3 DAYS IN A ROW OF ZERO PAGES IS NOT AN ACCIDENT, IT'S A PATTERN. FIX IT TODAY.",
      ),
      findsOneWidget,
    );

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Smart local insights calculate metrics correctly based on mock database logs', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final today = DateTime.now();

    final h1 = HabitModel(
      id: 'h1',
      userId: 'u1',
      title: 'Water Intake',
      description: 'hydrate',
      category: 'health',
      icon: '💧',
      colorValue: 0xFF4D96FF,
      reminderTime: '08:00',
      activeDays: const ['mon', 'wed', 'fri'],
      createdAt: today.subtract(const Duration(days: 40)),
    );

    final h2 = HabitModel(
      id: 'h2',
      userId: 'u1',
      title: 'Math Study',
      description: 'calculus',
      category: 'study',
      icon: '📚',
      colorValue: 0xFFC77DFF,
      reminderTime: '15:00',
      activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      createdAt: today.subtract(const Duration(days: 40)),
    );

    // Mock logs for h1: 100% completed
    final List<HabitLogModel> h1Logs = [];
    // Mock logs for h2: only 20% completed
    final List<HabitLogModel> h2Logs = [];

    DateTime current = today.subtract(const Duration(days: 30));
    while (current.isBefore(today)) {
      if (h1.activeDays.contains(['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][current.weekday - 1])) {
        h1Logs.add(HabitLogModel(id: 'l1_${current.day}', habitId: 'h1', date: current, isCompleted: true));
      }
      if (current.weekday == 1) { // complete h2 only on mondays to make monday most productive
        h2Logs.add(HabitLogModel(id: 'l2_${current.day}', habitId: 'h2', date: current, isCompleted: true));
      }
      current = current.add(const Duration(days: 1));
    }

    final repo = MockHabitRepository(
      habits: [h1, h2],
      logs: {'h1': h1Logs, 'h2': h2Logs},
      streaks: {'h1': 14, 'h2': 2},
    );

    final sl = GetIt.instance;
    sl.registerSingleton<HabitRepository>(repo);
    sl.registerSingleton<GeminiService>(MockGeminiService());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => FakeAuthBloc()),
          BlocProvider<HabitBloc>(create: (_) => FakeHabitBloc(habits: [h1, h2], streaks: const {'h1': 14, 'h2': 2})),
        ],
        child: const MaterialApp(
          home: AIInsightsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify calculated grid values
    expect(find.text('WATER INTAKE'), findsOneWidget); // Strongest habit name
    expect(find.text('MATH STUDY'), findsOneWidget); // Weakest habit name
    expect(find.text('14 DAYS'), findsOneWidget); // Best streak record

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Summary generator animates loader and displays Gemini summary response when API key is active', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final prefs = GetIt.instance<SharedPreferences>();
    await prefs.setString('gemini_api_key', 'valid_gemini_api_key_123');

    final sl = GetIt.instance;
    sl.registerSingleton<HabitRepository>(MockHabitRepository());
    sl.registerSingleton<GeminiService>(MockGeminiService(
      insightResponse: "BRUTAL TRUTH FROM GEMINI AI COACH: YOU SCRATCHED VITAMINS ENTIRELY, DO BETTER!",
    ));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => FakeAuthBloc()),
          BlocProvider<HabitBloc>(create: (_) => FakeHabitBloc()),
        ],
        child: const MaterialApp(
          home: AIInsightsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Badge should be active (AI ON)
    expect(find.text('AI ON ✓'), findsOneWidget);

    // Tap Generate Weekly Summary
    await tester.tap(find.text('GENERATE REPORT ✦'));
    // Pump to verify progress loading loader display
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('COMPILING TRUTH...'), findsOneWidget);

    // Pump past the simulated delay duration
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify AI response shows up
    expect(find.text("BRUTAL TRUTH FROM GEMINI AI COACH: YOU SCRATCHED VITAMINS ENTIRELY, DO BETTER!"), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
