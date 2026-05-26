import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_flow/features/habit/add_habit_screen.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
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
    const UserModel(uid: 'u1', email: 'u1@test.com', displayName: 'Test User')
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
}

class FakeHabitBloc extends HabitBloc {
  FakeHabitBloc() : super(habitRepository: DummyHabitRepository());
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AddHabitScreen UI elements exist and render correctly', (WidgetTester tester) async {
    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: const MaterialApp(home: AddHabitScreen()),
      ),
    );

    // Allow staggered animations to run without hanging on loop animations
    await tester.pump(const Duration(seconds: 2));

    // Verify UI components are visible on screen
    expect(find.text('NEW HABIT'), findsOneWidget);
    expect(find.text('01 — IDENTITY'), findsOneWidget);
    expect(find.text('02 — CATEGORY'), findsOneWidget);
    expect(find.text('03 — COLOR'), findsOneWidget);
    expect(find.text('04 — SCHEDULE'), findsOneWidget);
    expect(find.text('HABIT NAME *'), findsOneWidget);
    expect(find.text('TAP TO\nCHOOSE\nICON'), findsOneWidget);
    expect(find.text('CREATE HABIT'), findsOneWidget);
  });
}
