import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/features/settings/settings_screen.dart';
import 'package:habit_flow/shared/widgets/main_layout.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_flow/shared/models/user_model.dart';

class FakeBadgesBox extends Fake implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Iterable get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  bool get isOpen => true;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  @override
  Map<dynamic, dynamic> toMap() => Map.unmodifiable(_data);

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);
}

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
    const UserModel(uid: 'u1', email: 'u1@test.com', displayName: 'Test User'),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sl = GetIt.instance;
    if (sl.isRegistered<SharedPreferences>()) {
      await sl.unregister<SharedPreferences>();
    }
    if (sl.isRegistered<Box>(instanceName: 'badgesBox')) {
      await sl.unregister<Box>(instanceName: 'badgesBox');
    }
    sl.registerSingleton<SharedPreferences>(prefs);
    sl.registerSingleton<Box>(FakeBadgesBox(), instanceName: 'badgesBox');
  });

  testWidgets(
    'SettingsScreen UI elements exist and render correctly in Neobrutalist style',
    (WidgetTester tester) async {
      // Set a large viewport so all list elements are immediately built and visible
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final themeCubit = ThemeCubit(sharedPreferences: prefs);
      final authBloc = FakeAuthBloc();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => themeCubit),
            BlocProvider<AuthBloc>(create: (_) => authBloc),
          ],
          child: const MaterialApp(
            home: MainLayout(location: '/settings', child: SettingsScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('SETTINGS'), findsNWidgets(2));

      // Verify sections are displayed
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('AI & DATA'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);

      // Verify user profile displays info
      expect(find.text('TEST USER'), findsOneWidget);
      expect(find.text('u1@test.com'), findsOneWidget);

      // Verify dark mode toggle switch is visible
      expect(find.text('DARK MODE'), findsOneWidget);
      expect(find.byType(NeobrutalistSwitch), findsAtLeastNWidgets(1));

      // Verify other cards exist
      expect(find.text('AI MOTIVATION SETTINGS'), findsOneWidget);
      expect(find.text('SIGN OUT'), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('Tapping the dark mode switch toggles theme mode', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(sharedPreferences: prefs);
    final authBloc = FakeAuthBloc();

    // Verify initial theme state (default is ThemeMode.dark)
    expect(themeCubit.state, ThemeMode.dark);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => themeCubit),
          BlocProvider<AuthBloc>(create: (_) => authBloc),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the first switch (Dark Mode toggle switch)
    await tester.tap(find.byType(NeobrutalistSwitch).first);
    await tester.pumpAndSettle();

    // Verify that the theme cubit state has toggled to light mode
    expect(themeCubit.state, ThemeMode.light);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'Tapping SIGN OUT button triggers Neobrutalist confirmation dialog',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final themeCubit = ThemeCubit(sharedPreferences: prefs);
      final authBloc = FakeAuthBloc();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => themeCubit),
            BlocProvider<AuthBloc>(create: (_) => authBloc),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog is NOT displayed yet
      expect(find.text('REALLY SIGN OUT?'), findsNothing);

      // Tap the SIGN OUT button
      await tester.tap(find.text('SIGN OUT'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.text('REALLY SIGN OUT?'), findsOneWidget);
      expect(find.text('YES, LOG OUT'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);

      // Tap CANCEL to close the dialog
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.text('REALLY SIGN OUT?'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    },
  );
}
