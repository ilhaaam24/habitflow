import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/features/settings/settings_screen.dart';
import 'package:habit_flow/core/theme/theme_cubit.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:habit_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_flow/shared/models/user_model.dart';

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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('SettingsScreen UI elements exist and render correctly in Neobrutalist style', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);
    final authBloc = FakeAuthBloc();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => themeCubit),
          BlocProvider<AuthBloc>(create: (_) => authBloc),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header elements
    expect(find.text('SETTINGS'), findsOneWidget);

    // Verify sections are displayed
    expect(find.text('01 — GENERAL'), findsOneWidget);
    expect(find.text('02 — AI INTEGRATION'), findsOneWidget);
    expect(find.text('03 — ABOUT'), findsOneWidget);

    // Verify user profile displays info
    expect(find.text('TEST USER'), findsOneWidget);
    expect(find.text('u1@test.com'), findsOneWidget);

    // Verify dark mode toggle switch is visible
    expect(find.text('DARK MODE'), findsOneWidget);
    expect(find.byType(NeobrutalistSwitch), findsOneWidget);

    // Verify other cards exist
    expect(find.text('AI MOTIVATION SETTINGS'), findsOneWidget);
    expect(find.text('BACK TO DASHBOARD'), findsOneWidget);
  });

  testWidgets('Tapping the dark mode switch toggles theme mode', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);
    final authBloc = FakeAuthBloc();

    // Verify initial theme state (default is ThemeMode.dark)
    expect(themeCubit.state, ThemeMode.dark);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => themeCubit),
          BlocProvider<AuthBloc>(create: (_) => authBloc),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the switch
    await tester.tap(find.byType(NeobrutalistSwitch));
    await tester.pumpAndSettle();

    // Verify that the theme cubit state has toggled to light mode
    expect(themeCubit.state, ThemeMode.light);
  });
}
