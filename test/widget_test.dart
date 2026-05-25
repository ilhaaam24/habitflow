// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_flow/features/auth/splash_screen.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_flow/features/auth/onboarding_screen.dart';
import 'package:habit_flow/shared/models/user_model.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<UserModel?> get authStateChanges => Stream.value(null);

  @override
  UserModel? getCurrentUser() => null;

  @override
  Future<UserModel> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    final authRepository = FakeAuthRepository();
    final authBloc = AuthBloc(authRepository: authRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      BlocProvider<AuthBloc>(
        create: (context) => authBloc,
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    // Verify that Splash screen is displayed.
    expect(find.text('HABIT'), findsOneWidget);
    expect(find.text('FLOW'), findsNWidgets(2));
  });

  testWidgets('OnboardingScreen PageView layout and navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingScreen()),
    );

    // Verify Page 1 elements are displayed
    expect(find.text('TRACK YOUR'), findsOneWidget);
    expect(find.text('HABITS.'), findsOneWidget);
    expect(find.text('01 / 03'), findsOneWidget);

    // Tap NEXT to transition to Page 2
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Verify Page 2 elements are displayed
    expect(find.text("DON'T BREAK THE"), findsOneWidget);
    expect(find.text('CHAIN.'), findsOneWidget);
    expect(find.text('02 / 03'), findsOneWidget);

    // Tap NEXT to transition to Page 3
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Verify Page 3 elements are displayed
    expect(find.text('YOUR AI COACH.'), findsOneWidget);
    expect(find.text('ALWAYS ON.'), findsOneWidget);
    expect(find.text('03 / 03'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
