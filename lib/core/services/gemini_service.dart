import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/habit/presentation/bloc/habit_bloc.dart';
import '../../features/habit/presentation/bloc/habit_state.dart';
import '../../features/habit/domain/repositories/habit_repository.dart';
import '../../shared/models/habit_log_model.dart';
import '../helpers/completion_rate_calculator.dart';

class GeminiService {
  final SharedPreferences sharedPreferences;
  final Dio dio;
  final HabitRepository habitRepository;

  GeminiService({
    required this.sharedPreferences,
    required this.dio,
    required this.habitRepository,
  });

  /// Sends a test query to verify if the provided API key is valid.
  Future<bool> testConnection(String apiKey) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
    try {
      final response = await dio.post(
        url,
        data: {
          "contents": [
            {
              "parts": [
                {"text": "Hello"},
              ],
            },
          ],
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Compiles dynamic statistics from context, builds prompt, calls Gemini, and returns motivation.
  Future<String> getMotivation(BuildContext context) async {
    final apiKey = sharedPreferences.getString('gemini_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      return "Tidak ada koneksi internet. Pelatih offline sementara, tapi Anda tetap harus disiplin hari ini!";
    }

    // 1. Get user name
    String name = 'User';
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      name = authState.user.displayName;
    }

    // 2. Get habit states
    final habitState = BlocProvider.of<HabitBloc>(context).state;
    if (habitState is! HabitLoaded || habitState.habits.isEmpty) {
      return "Mulailah dengan menambahkan habit pertama Anda untuk membangun disiplin hari ini!";
    }

    final habits = habitState.habits;
    final todayLogs = habitState.todayLogs;
    final streaks = habitState.streaks;

    // 3. Compile stats
    final habitList = habits.map((h) => h.title).join(', ');

    // Find best streak
    int bestStreak = 0;
    if (streaks.isNotEmpty) {
      for (final streakVal in streaks.values) {
        if (streakVal > bestStreak) {
          bestStreak = streakVal;
        }
      }
    }

    // Calculate today completion
    final completedToday = todayLogs.where((log) => log.isCompleted).length;
    final todayCompletion = (completedToday / habits.length * 100).round();

    // Fetch weekly logs for each habit
    final Map<String, List<HabitLogModel>> habitsLogs = {};
    for (final habit in habits) {
      try {
        final logs = await habitRepository.getLogsForHabit(habit.id);
        habitsLogs[habit.id] = logs;
      } catch (_) {
        habitsLogs[habit.id] = [];
      }
    }

    // Calculate weekly completion
    final weekCompletion = CompletionRateCalculator.calculateMultiple(
      habits: habits,
      habitsLogs: habitsLogs,
      days: 7,
    );

    // Calculate best & worst habits based on weekly rate
    String bestHabit = 'None';
    String worstHabit = 'None';
    int maxRate = -1;
    int minRate = 101;

    for (final habit in habits) {
      final logs = habitsLogs[habit.id] ?? [];
      final rate = CompletionRateCalculator.calculate(
        habit: habit,
        logs: logs,
        days: 7,
      );

      if (rate > maxRate) {
        maxRate = rate;
        bestHabit = "${habit.title} ($rate%)";
      }
      if (rate < minRate) {
        minRate = rate;
        worstHabit = "${habit.title} ($rate%)";
      }
    }

    // 4. Construct prompt
    final prompt =
        """
Kamu adalah AI coach untuk habit tracker.
Data user:
- Nama: $name
- Habit aktif: $habitList
- Streak terbaik hari ini: $bestStreak hari
- Completion hari ini: $todayCompletion%
- Completion minggu ini: $weekCompletion%
- Habit paling konsisten: $bestHabit
- Habit paling sering skip: $worstHabit

Berikan 1 pesan motivasi personal dalam Bahasa Indonesia,
2-3 kalimat, positif, spesifik berdasarkan data di atas.
Jangan gunakan emoji berlebihan.
""";

    return _callGemini(apiKey, prompt);
  }

  /// Generates a brutally honest weekly insight/report card from the provided summary data.
  Future<String> getInsight(String habitData) async {
    final apiKey = sharedPreferences.getString('gemini_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      return "Tidak ada koneksi internet. Pelatih offline sementara, tapi Anda tetap harus disiplin hari ini!";
    }

    final prompt =
        """
Kamu adalah AI coach untuk habit tracker yang sangat jujur, blak-blakan, dan tegas (brutally honest coach).
Data aktivitas mingguan: $habitData

Berikan Weekly Report Card dalam Bahasa Indonesia.
Gaya bicara: tegas, no-nonsense.
Rangkum performa, puji konsistensi tapi kritik keras kegagalan/kemalasan.
Format: 3-4 kalimat, ALL CAPS.
""";

    return _callGemini(apiKey, prompt);
  }

  Future<String> _callGemini(String apiKey, String prompt) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
    try {
      final response = await dio.post(
        url,
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map?;
          if (content != null) {
            final parts = content['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              return parts[0]['text'] as String? ?? 'Gagal membaca respon AI.';
            }
          }
        }
      }
      return "Gagal mendapatkan respon valid dari Gemini.";
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return "Tidak ada koneksi internet. Pelatih offline sementara, tapi Anda tetap harus disiplin hari ini!";
      }
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 400) {
          return "Koneksi gagal. API Key Anda salah atau tidak valid. Silakan periksa kembali pengaturan Anda.";
        } else if (statusCode == 429) {
          return "Limit API tercapai. Pelatih butuh istirahat sejenak! Silakan coba lagi beberapa saat lagi.";
        }
      }
      return "Gagal menghubungi Gemini. Error: ${e.message}";
    } catch (e) {
      return "Gagal mendapatkan motivasi AI. Error: $e";
    }
  }
}
