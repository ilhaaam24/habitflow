import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_flow/features/habit/home_screen.dart';
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
        habits: const [],
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
        child: const MaterialApp(home: HomeScreen()),
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
}
