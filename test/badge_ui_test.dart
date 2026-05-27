import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/shared/models/badge_model.dart';
import 'package:habit_flow/core/services/badge_service.dart';
import 'package:habit_flow/shared/widgets/badge_unlock_dialog.dart';
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
    const UserModel(uid: 'u1', email: 'u1@test.com', displayName: 'Rafi Ahmad'),
  );
}

class FakeBadgesBox extends Fake implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) => _data[key] ?? defaultValue;

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
  dynamic getAt(int index) => _data.values.elementAt(index);

  @override
  Future<void> putAt(int index, dynamic value) async {
    _data[_data.keys.elementAt(index)] = value;
  }

  @override
  Future<int> add(dynamic value) async {
    final nextKey = _data.length;
    _data[nextKey] = value;
    return nextKey;
  }

  @override
  Future<Iterable<int>> addAll(Iterable values) async {
    final keys = <int>[];
    for (final val in values) {
      keys.add(await add(val));
    }
    return keys;
  }

  @override
  Future<void> putAll(Map entries) async {
    _data.addAll(entries);
  }

  @override
  Future<void> deleteAt(int index) async {
    _data.remove(_data.keys.elementAt(index));
  }

  @override
  Future<void> deleteAll(Iterable keys) async {
    for (final k in keys) {
      _data.remove(k);
    }
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> compact() async {}

  @override
  Future<void> close() async {}

  @override
  String? get path => null;

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  @override
  dynamic keyAt(int index) => _data.keys.elementAt(index);

  @override
  Map<dynamic, dynamic> toMap() => Map.unmodifiable(_data);

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);
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
    if (sl.isRegistered<Box>(instanceName: 'badgesBox')) {
      await sl.unregister<Box>(instanceName: 'badgesBox');
    }
    if (sl.isRegistered<BadgeService>()) {
      await sl.unregister<BadgeService>();
    }

    sl.registerSingleton<SharedPreferences>(prefs);
  });

  testWidgets('BadgeUnlockDialog renders icon, name, and description in Neobrutalist styling', (WidgetTester tester) async {
    const badge = BadgeModel(
      id: 'first_flame',
      name: 'First Flame',
      description: 'Complete habit pertama kali',
      icon: '🔥',
      colorValue: 0xFFFFD93D,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BadgeUnlockDialog(badge: badge),
        ),
      ),
    );

    expect(find.text('🔥'), findsOneWidget);
    expect(find.text('BADGE UNLOCKED! 🏆'), findsOneWidget);
    expect(find.text('FIRST FLAME'), findsOneWidget);
    expect(find.text('COMPLETE HABIT PERTAMA KALI'), findsOneWidget);
    expect(find.text('AWESOME! ⚡'), findsOneWidget);
  });

  testWidgets('SettingsScreen displays achievements card with locked/unlocked state grid correctly', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final sl = GetIt.instance;
    final badgesBox = FakeBadgesBox();
    // Pre-unlock first_flame and warrior_3
    badgesBox.put('first_flame', true);
    badgesBox.put('warrior_3', true);

    sl.registerSingleton<Box>(badgesBox, instanceName: 'badgesBox');

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(GetIt.instance<SharedPreferences>())),
          BlocProvider<AuthBloc>(create: (_) => FakeAuthBloc()),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Achievements Card is rendered
    expect(find.text('🏆 ACHIEVEMENTS'), findsOneWidget);
    expect(find.text('2 / 7 UNLOCKED'), findsOneWidget);

    // Verify tooltips/icons exist
    expect(find.byKey(const Key('badge_tooltip_first_flame')), findsOneWidget);
    expect(find.byKey(const Key('badge_tooltip_warrior_3')), findsOneWidget);
    expect(find.byKey(const Key('badge_tooltip_champion_7')), findsOneWidget);

    // Tap on First Flame (unlocked)
    await tester.tap(find.byKey(const Key('badge_tooltip_first_flame')));
    await tester.pumpAndSettle();

    // Verify details dialog displays UNLOCKED
    expect(find.text('UNLOCKED 🏆'), findsOneWidget);
    expect(find.text('FIRST FLAME'), findsOneWidget);
    expect(find.text('COMPLETE HABIT PERTAMA KALI'), findsOneWidget);

    // Close detail dialog
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    // Tap on Week Champion (locked)
    await tester.tap(find.byKey(const Key('badge_tooltip_champion_7')));
    await tester.pumpAndSettle();

    // Verify details dialog displays LOCKED
    expect(find.text('LOCKED 🔒'), findsOneWidget);
    expect(find.text('WEEK CHAMPION'), findsOneWidget);
    expect(find.text('STREAK 7 HARI'), findsOneWidget);

    // Close details dialog
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    await tester.binding.setSurfaceSize(null);
  });
}
