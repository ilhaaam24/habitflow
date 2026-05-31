import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_flow/features/habit/home_screen.dart';
import 'package:habit_flow/shared/widgets/main_layout.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/shared/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:habit_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_flow/features/habit/domain/repositories/habit_repository.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/shared/models/habit_log_model.dart';

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
    const UserModel(uid: 'u1', email: 'u1@test.com', displayName: 'Rafi Ahmad')
  );
}

class DummyHabitRepository implements HabitRepository {
  @override
  Future<void> addHabit(HabitModel habit) async {}
  @override
  Future<void> updateHabit(HabitModel habit) async {}
  @override
  Future<void> deleteHabit(String id) async {}
  @override
  Stream<List<HabitModel>> getHabits(String userId) => const Stream.empty();
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
  FakeHabitBloc() : super(habitRepository: DummyHabitRepository());

  @override
  void add(HabitEvent event) {}

  @override
  HabitState get state => HabitLoaded(
        habits: [
          HabitModel(
            id: 'dummy_1',
            title: 'MORNING HYDRATION',
            icon: '💧',
            colorValue: 0xFF4D96FF,
            category: '💧 HEALTH',
            userId: 'u1',
            description: '',
            reminderTime: '08:00',
            activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
            createdAt: DateTime(2026, 1, 1),
          ),
          HabitModel(
            id: 'dummy_2',
            title: 'EVENING RUN',
            icon: '🏃',
            colorValue: 0xFFFF6B6B,
            category: '🏃 FITNESS',
            userId: 'u1',
            description: '',
            reminderTime: '18:00',
            activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
            createdAt: DateTime(2026, 1, 1),
          ),
          HabitModel(
            id: 'dummy_3',
            title: 'READ 20 PAGES',
            icon: '📚',
            colorValue: 0xFFC77DFF,
            category: '📚 LEARNING',
            userId: 'u1',
            description: '',
            reminderTime: '21:00',
            activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        todayLogs: const [],
        selectedDate: DateTime.now(),
      );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HomeScreen UI elements render correctly in Neobrutalist style', (WidgetTester tester) async {
    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(
          home: MainLayout(
            location: '/home',
            child: HomeScreen(),
          ),
        ),
      ),
    );

    // Let initial frame load and advance time to trigger FAB animation timer
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Top bar greeting text
    expect(find.textContaining('GOOD'), findsOneWidget);
    expect(find.textContaining('RAFI'), findsOneWidget);

    // Verify Progress Card labels
    expect(find.text("TODAY'S SCORE"), findsOneWidget);
    expect(find.text("STREAK"), findsOneWidget);
    expect(find.text("DAYS"), findsOneWidget);

    // Verify Section header
    expect(find.text('MY HABITS'), findsOneWidget);
    expect(find.text('SEE ALL →'), findsOneWidget);

    // Verify Habit list items
    expect(find.text('MORNING HYDRATION'), findsOneWidget);
    expect(find.text('EVENING RUN'), findsOneWidget);
    expect(find.text('READ 20 PAGES'), findsOneWidget);

    // Verify Bottom Navigation items
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('STATS'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);

    // Verify FAB and sticker badge
    expect(find.text('+'), findsOneWidget);
    expect(find.text('NEW!'), findsOneWidget);
  });

  testWidgets('HomeScreen renders NO HABITS YET empty state when habits list is empty', (WidgetTester tester) async {
    final authBloc = FakeAuthBloc();
    final habitBloc = FakeEmptyHabitBloc();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify Empty State elements
    expect(find.text('NO HABITS YET.'), findsOneWidget);
    expect(find.text('ADD FIRST HABIT'), findsOneWidget);
    expect(find.text('EMPTY!'), findsOneWidget);
  });
}

class FakeEmptyHabitBloc extends HabitBloc {
  FakeEmptyHabitBloc() : super(habitRepository: DummyHabitRepository());

  @override
  void add(HabitEvent event) {}

  @override
  HabitState get state => HabitLoaded(
        habits: const [],
        todayLogs: const [],
        selectedDate: DateTime.now(),
      );
}
