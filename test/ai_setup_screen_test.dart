import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_flow/features/settings/ai_settings_screen.dart';

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
    sl.registerSingleton<SharedPreferences>(prefs);
  });

  testWidgets('AISettingsScreen UI elements render correctly in NOT CONNECTED state', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    await tester.pumpWidget(
      const MaterialApp(
        home: AISettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Header elements check
    expect(find.text('AI SETUP'), findsOneWidget);
    expect(find.text('←'), findsOneWidget);

    // 2. Default NOT CONNECTED status banner check
    expect(find.text('NOT CONNECTED'), findsOneWidget);
    expect(find.text('Add your API key to unlock AI'), findsOneWidget);
    expect(find.text('!'), findsOneWidget);

    // 3. How It Works steps check
    expect(find.text('HOW IT WORKS'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('GET FREE API KEY'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('PASTE KEY SECURELY'), findsOneWidget);
    expect(find.text('03'), findsOneWidget);
    expect(find.text('ACTIVATE COACH'), findsOneWidget);

    // 4. Get Free Key link button check
    expect(find.text('GET YOUR FREE API KEY'), findsOneWidget);
    expect(find.text('makersuite.google.com →'), findsOneWidget);
    expect(find.text('↗'), findsOneWidget);

    // 5. Secure text field placeholder and label check
    expect(find.text('YOUR API KEY'), findsOneWidget);
    expect(find.text('SHOW / HIDE KEY'), findsOneWidget);
    expect(find.text('0 CHARS'), findsOneWidget);

    // 6. dashed privacy note check
    expect(find.text('STORED ONLY ON YOUR DEVICE. WE NEVER SEE YOUR KEY.'), findsOneWidget);

    // 7. Checkboxes unlock checklist check
    expect(find.text("YOU'LL UNLOCK"), findsOneWidget);
    expect(find.text('DAILY AI MOTIVATION'), findsOneWidget);
    expect(find.text('BRUTALLY HONEST COACHING'), findsOneWidget);
    expect(find.text('WEEKLY PROGRESS REPORTS'), findsOneWidget);
    expect(find.text('BEHAVIORAL PATTERN ANALYSIS'), findsOneWidget);
    expect(find.text('✓'), findsAtLeastNWidgets(4));

    // Secondary REMOVE button should NOT show since no key is connected initially
    expect(find.text('✕ REMOVE API KEY'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Show/Hide key toggles obscurity state and char count updates dynamically', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    await tester.pumpWidget(
      const MaterialApp(
        home: AISettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Initially textfield obscureText is true
    final TextField textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, isTrue);

    // Enter fake key
    await tester.enterText(find.byType(TextField), 'AIzaSyFake123');
    await tester.pumpAndSettle();

    // Characters count should display "13 CHARS"
    expect(find.text('13 CHARS'), findsOneWidget);

    // Toggle obscure text
    await tester.tap(find.text('SHOW / HIDE KEY'));
    await tester.pumpAndSettle();

    // Verify obscureText is now false
    final TextField textFieldToggled = tester.widget<TextField>(find.byType(TextField));
    expect(textFieldToggled.obscureText, isFalse);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Save key triggers simulated loader testing and updates to CONNECTED state and allows removal', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    await tester.pumpWidget(
      const MaterialApp(
        home: AISettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Fill key
    await tester.enterText(find.byType(TextField), 'AIzaSyTestingKey');
    await tester.pumpAndSettle();

    // Tap Save Key
    await tester.tap(find.text('TEST & SAVE KEY →'));
    // Do NOT settle immediately because the delay is asynchronous. Pump to trigger state change
    await tester.pump(const Duration(milliseconds: 100));

    // Verify testing status text is shown on button
    expect(find.text('TESTING KEY...'), findsOneWidget);

    // Pump past the 1-second delay
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Status Banner should now show CONNECTED
    expect(find.text('CONNECTED'), findsOneWidget);
    expect(find.text('Your Gemini API key is active'), findsOneWidget);
    expect(find.text('✓'), findsAtLeastNWidgets(5)); // 4 checkbox ticks + 1 banner tick

    // Secondary REMOVE key button should now be visible
    expect(find.text('✕ REMOVE API KEY'), findsOneWidget);

    // Tap REMOVE API KEY
    await tester.tap(find.text('✕ REMOVE API KEY'));
    await tester.pumpAndSettle();

    // Banner should go back to NOT CONNECTED
    expect(find.text('NOT CONNECTED'), findsOneWidget);
    expect(find.text('✕ REMOVE API KEY'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });
}
