import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_flow/features/habit/habit_detail_screen.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
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
        const UserModel(
          uid: 'u1',
          email: 'u1@test.com',
          displayName: 'Test User',
        ),
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
  Future<List<HabitLogModel>> getLogsForDate(
    String userId,
    DateTime date,
  ) async => [];
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

  testWidgets('HabitDetailScreen renders Evening Run content correctly in Neobrutalist style', (
    WidgetTester tester,
  ) async {
    // Set a large screen size to prevent sliver virtualization from hiding widgets off-screen
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();
    final dummyRepo = DummyHabitRepository();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: MaterialApp(
          home: HabitDetailScreen(
            id: 'dummy_2',
            repository: dummyRepo,
          ),
        ),
      ),
    );

    // Initial frame
    await tester.pumpAndSettle();

    // Verify Title and tags
    expect(find.text('EVENING RUN'), findsOneWidget);
    expect(find.text('🏃 FITNESS'), findsOneWidget);
    expect(find.text('ACTIVE ✓'), findsOneWidget);
    expect(find.text('🏃'), findsOneWidget);

    // Verify stats grid labels
    expect(find.text('CURRENT STREAK'), findsOneWidget);
    expect(find.text('SUCCESS RATE'), findsOneWidget);
    expect(find.text('TOTAL COMPLETED'), findsOneWidget);
    expect(find.text('BEST STREAK'), findsOneWidget);

    // Verify dynamic stats values calculated from generated mock logs
    // 23 current streak, 27 total completed, 23 best streak, 90% success rate
    final valueTexts = tester.widgetList<Text>(
      find.byWidgetPredicate((w) => w is Text && w.style?.fontSize == 48),
    ).map((t) => t.data).toList();
    expect(valueTexts.length, equals(5));
    expect(valueTexts.where((t) => t == '23').length, equals(2));
    expect(valueTexts.where((t) => t == '27').length, equals(1));
    expect(valueTexts.where((t) => t == '90%').length, equals(1));
    expect(valueTexts.where((t) => t == '🏃').length, equals(1));

    // Verify other UI sections
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('MONTHLY VIEW'), findsOneWidget);
    expect(find.text('REMINDER'), findsOneWidget);
    expect(find.text('DELETE HABIT'), findsOneWidget);
  });

  testWidgets('HabitDetailScreen reminder switch toggles and delete dialog pops up', (
    WidgetTester tester,
  ) async {
    // Set a large screen size to prevent sliver virtualization from hiding widgets off-screen
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authBloc = FakeAuthBloc();
    final habitBloc = FakeHabitBloc();
    final dummyRepo = DummyHabitRepository();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<HabitBloc>(create: (_) => habitBloc),
        ],
        child: MaterialApp(
          home: HabitDetailScreen(
            id: 'dummy_2',
            repository: dummyRepo,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify switch is initially ON (default)
    final NeobrutalistSwitch neobrutalistSwitch = tester.widget(
      find.byType(NeobrutalistSwitch),
    );
    expect(neobrutalistSwitch.value, isTrue);

    // Tap the switch to toggle it OFF
    await tester.tap(find.byType(NeobrutalistSwitch));
    await tester.pumpAndSettle();

    final NeobrutalistSwitch toggledSwitch = tester.widget(
      find.byType(NeobrutalistSwitch),
    );
    expect(toggledSwitch.value, isFalse);

    // Tap Delete button
    await tester.tap(find.text('DELETE HABIT'));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('DELETE HABIT?'), findsOneWidget);
    expect(
      find.text(
        'Are you sure you want to delete this habit? This action cannot be undone.',
      ),
      findsOneWidget,
    );
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('DELETE'), findsOneWidget);
  });
}
