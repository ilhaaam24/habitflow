import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

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

// Dummy classes for mocks
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
  final AuthState fakeState;
  FakeAuthBloc(this.fakeState) : super(authRepository: DummyAuthRepository());

  @override
  AuthState get state => fakeState;
}

class MockHabitRepository implements HabitRepository {
  final List<HabitLogModel> Function(String)? getLogsHandler;

  MockHabitRepository({this.getLogsHandler});

  @override
  Future<void> addHabit(HabitModel habit) async {}
  @override
  Future<void> updateHabit(HabitModel habit) async {}
  @override
  Future<void> deleteHabit(String id) async {}
  @override
  Stream<List<HabitModel>> getHabits(String userId) => Stream.value([]);
  @override
  Future<void> logHabit(HabitLogModel log) async {}
  @override
  Future<List<HabitLogModel>> getLogsForDate(String userId, DateTime date) async => [];
  @override
  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    if (getLogsHandler != null) {
      return getLogsHandler!(habitId);
    }
    return [];
  }
  @override
  Future<int> calculateStreak(String habitId) async => 0;
  @override
  Future<int> getLongestStreak(String habitId) async => 0;
}

class FakeHabitBloc extends HabitBloc {
  final HabitState fakeState;
  FakeHabitBloc(this.fakeState) : super(habitRepository: MockHabitRepository());

  @override
  HabitState get state => fakeState;
}

class FakeDio extends Fake implements Dio {
  final Future<Response> Function(String, {dynamic data, Options? options})? postHandler;
  FakeDio({this.postHandler});

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (postHandler != null) {
      final res = await postHandler!(path, data: data, options: options);
      return res as Response<T>;
    }
    throw UnimplementedError();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('GeminiService Connection Tests', () {
    test('testConnection returns true on successful 200 response', () async {
      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {"contents": []},
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: MockHabitRepository(),
      );

      final result = await service.testConnection('fake_key');
      expect(result, isTrue);
    });

    test('testConnection returns false on 400 or other errors', () async {
      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 400,
            ),
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: MockHabitRepository(),
      );

      final result = await service.testConnection('fake_key');
      expect(result, isFalse);
    });
  });

  group('GeminiService getMotivation Tests', () {
    testWidgets('getMotivation returns offline fallback when no key is set', (WidgetTester tester) async {
      final service = GeminiService(
        sharedPreferences: prefs,
        dio: FakeDio(),
        habitRepository: MockHabitRepository(),
      );

      await tester.pumpWidget(Container());
      final BuildContext context = tester.element(find.byType(Container));

      final result = await service.getMotivation(context);
      expect(result, contains('offline'));
    });

    testWidgets('getMotivation compiles stats and sends correctly styled request', (WidgetTester tester) async {
      await prefs.setString('gemini_api_key', 'my_key_123');

      final authBloc = FakeAuthBloc(AuthAuthenticated(
        const UserModel(uid: 'u1', email: 'rafi@test.com', displayName: 'Rafi Ahmad'),
      ));

      final today = DateTime.now();
      final h1 = HabitModel(
        id: 'h1',
        userId: 'u1',
        title: 'Running',
        description: 'cardio',
        category: 'fitness',
        icon: '🏃',
        colorValue: 0xFFFF6B6B,
        reminderTime: '06:00',
        activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        createdAt: today.subtract(const Duration(days: 10)),
      );

      final habitBloc = FakeHabitBloc(HabitLoaded(
        habits: [h1],
        todayLogs: [HabitLogModel(id: 'l1', habitId: 'h1', date: today, isCompleted: true)],
        selectedDate: today,
        streaks: const {'h1': 5},
      ));

      final habitRepo = MockHabitRepository(
        getLogsHandler: (habitId) {
          return [
            HabitLogModel(id: 'l_old', habitId: 'h1', date: today.subtract(const Duration(days: 1)), isCompleted: true),
          ];
        },
      );

      String? capturedPrompt;
      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          final body = data as Map;
          capturedPrompt = body['contents'][0]['parts'][0]['text'] as String;
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              "candidates": [
                {
                  "content": {
                    "parts": [
                      {"text": "Semangat terus Rafi! Streak Running kamu luar biasa."}
                    ]
                  }
                }
              ]
            },
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: habitRepo,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => authBloc),
            BlocProvider<HabitBloc>(create: (_) => habitBloc),
          ],
          child: Builder(
            builder: (context) {
              return Container();
            },
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(Container));
      final result = await service.getMotivation(context);

      expect(result, equals('Semangat terus Rafi! Streak Running kamu luar biasa.'));
      expect(capturedPrompt, contains('Rafi Ahmad'));
      expect(capturedPrompt, contains('Running'));
    });
  });

  group('GeminiService getInsight Tests', () {
    test('getInsight requests a brutally honest coach response', () async {
      await prefs.setString('gemini_api_key', 'my_key_123');

      String? capturedPrompt;
      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          final body = data as Map;
          capturedPrompt = body['contents'][0]['parts'][0]['text'] as String;
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              "candidates": [
                {
                  "content": {
                    "parts": [
                      {"text": "PERFORMA KAMU LUAR BIASA! TAPI SELESAIKAN VITAMINS!"}
                    ]
                  }
                }
              ]
            },
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: MockHabitRepository(),
      );

      final result = await service.getInsight('Vitamins completion rate: 31%');
      expect(result, equals('PERFORMA KAMU LUAR BIASA! TAPI SELESAIKAN VITAMINS!'));
      expect(capturedPrompt, contains('brutally honest'));
      expect(capturedPrompt, contains('Vitamins completion rate: 31%'));
    });
  });

  group('GeminiService Resilient Error Handling Tests', () {
    test('getInsight handles invalid API key (400) correctly', () async {
      await prefs.setString('gemini_api_key', 'invalid_key');

      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 400,
            ),
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: MockHabitRepository(),
      );

      final result = await service.getInsight('Some data');
      expect(result, contains('API Key Anda salah atau tidak valid'));
    });

    test('getInsight handles rate limiting (429) correctly', () async {
      await prefs.setString('gemini_api_key', 'valid_key');

      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 429,
            ),
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: MockHabitRepository(),
      );

      final result = await service.getInsight('Some data');
      expect(result, contains('Limit API tercapai'));
    });

    test('getInsight handles connection timeout (offline) correctly', () async {
      await prefs.setString('gemini_api_key', 'valid_key');

      final dio = FakeDio(
        postHandler: (path, {data, options}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            type: DioExceptionType.connectionTimeout,
          );
        },
      );

      final service = GeminiService(
        sharedPreferences: prefs,
        dio: dio,
        habitRepository: MockHabitRepository(),
      );

      final result = await service.getInsight('Some data');
      expect(result, contains('Tidak ada koneksi internet'));
    });
  });
}
