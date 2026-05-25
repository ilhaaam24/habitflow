# 📋 PRD, Backlog, Sprint & Tasks — AI Habit Tracker

----------

## 📌 PRODUCT REQUIREMENTS DOCUMENT (PRD)

----------

### 1. Overview

Field

Detail

**Product Name**

HabitFlow AI

**Platform**

Android (Flutter)

**Target User**

18–30 tahun, produktif, tech-savvy

**Goal**

Membantu user membangun kebiasaan baik dengan tracking harian + insight AI

**Timeline**

8 Minggu

**Publish Target**

Google Play Store

----------

### 2. Problem Statement

text

```
Banyak orang gagal membangun kebiasaan baik karena:
- Tidak ada sistem tracking yang menyenangkan
- Tidak ada motivasi personal
- Aplikasi habit tracker yang ada terlalu kompleks
  atau terlalu membosankan
```

----------

### 3. Solution

text

```
HabitFlow AI:
- Tracking habit harian yang simple & visual
- AI memberikan motivasi & insight personal
- UI modern, smooth, tidak membosankan
- User bisa pakai AI gratis dengan API key sendiri
```

----------

### 4. User Persona

text

```
Nama     : Rafi, 22 tahun
Profesi  : Mahasiswa / Fresh Graduate
Pain     : Sering lupa habit, tidak konsisten
Goal     : Bangun rutinitas sehat & produktif
Device   : Android mid-range
```

----------

### 5. Feature List & Priority

Priority

Feature

Keterangan

🔴 P0

Auth (Google Login)

Wajib ada

🔴 P0

Habit CRUD

Core feature

🔴 P0

Daily Checklist

Core feature

🔴 P0

Streak Counter

Core feature

🔴 P0

Local Notification

Reminder harian

🟡 P1

Statistik & Grafik

Completion rate, weekly

🟡 P1

Calendar View

Visual progress

🟡 P1

Dark Mode

UI preference

🟢 P2

AI Motivation (Gemini)

User input API key sendiri

🟢 P2

Smart Insight

Analisis pola habit

🟢 P2

Achievement Badge

Gamifikasi

⚪ P3

Export PDF

Nice to have

⚪ P3

Widget Homescreen

Nice to have

----------

### 6. AI Feature — Strategi BYOK (Bring Your Own Key)

text

```
❓ Masalah:
   Kalau kamu yang sediakan API key → kamu yang bayar
   Kalau ramai user → biaya meledak

✅ Solusi: BYOK (Bring Your Own Key)
   User input API key Gemini mereka sendiri
   API key disimpan LOKAL di device (SharedPreferences/Hive)
   Tidak pernah dikirim ke servermu
   Gratis untuk kamu, gratis untuk user (Gemini ada free tier)

📋 Flow:
   User buka menu AI Settings
   → Input Gemini API key
   → Key disimpan lokal
   → App pakai key itu untuk call Gemini API
   → Kalau tidak ada key → fitur AI terkunci, tampil prompt setup
```

----------

### 7. Tech Stack

text

```
Frontend    : Flutter (Dart)
State Mgmt  : flutter_bloc / Cubit
Navigation  : GoRouter
Database    : Hive (local) + Firebase Firestore (cloud)
Auth        : Firebase Auth (Google Sign-In)
Notification: flutter_local_notifications
AI          : Google Gemini API (user's own key)
HTTP        : Dio
Charts      : fl_chart
Storage     : SharedPreferences (API key), Hive (habits)
```

----------

### 8. Non-Functional Requirements

text

```
✅ Performa  : Animasi 60fps, load < 2 detik
✅ Offline   : Habit bisa dicek tanpa internet
✅ Keamanan  : API key tidak pernah ke server
✅ UX        : Onboarding < 1 menit
✅ Size      : APK < 30MB
✅ Android   : Minimum SDK 21 (Android 5.0)
```

----------

----------

## 📦 PRODUCT BACKLOG

----------

### EPIC 1 — Foundation & Auth

text

```
EPIC-01 : Setup Project & Architecture
EPIC-02 : Authentication Flow
EPIC-03 : Onboarding Flow
```

### EPIC 2 — Core Habit Feature

text

```
EPIC-04 : Habit Management (CRUD)
EPIC-05 : Daily Checklist
EPIC-06 : Streak System
```

### EPIC 3 — Notification & UX

text

```
EPIC-07 : Local Notification / Reminder
EPIC-08 : UI Polish (Dark Mode, Animasi)
EPIC-09 : Calendar View
```

### EPIC 4 — Analytics

text

```
EPIC-10 : Statistik & Grafik
EPIC-11 : Completion Rate
```

### EPIC 5 — AI Feature

text

```
EPIC-12 : AI Settings (BYOK Input)
EPIC-13 : AI Motivation Message
EPIC-14 : Smart Insight
```

### EPIC 6 — Gamifikasi & Extra

text

```
EPIC-15 : Achievement Badge
EPIC-16 : Play Store Preparation
```

----------

----------

## 🗓️ SPRINT PLAN

----------

### 🏃 SPRINT 1 — Week 1–2

**Goal: Project jalan, auth beres, habit bisa ditambah**

----------

### 🏃 SPRINT 2 — Week 3–4

**Goal: Daily checklist, streak, notifikasi, UI dasar selesai**

----------

### 🏃 SPRINT 3 — Week 5–6

**Goal: Statistik, kalender, dark mode, UI premium**

----------

### 🏃 SPRINT 4 — Week 7–8

**Goal: AI feature, badge, Polish, Publish Play Store**

----------

----------

## ✅ TASK BREAKDOWN PER SPRINT

----------

## 🏃 SPRINT 1 — Foundation & Core (Week 1–2)

----------

### 📁 EPIC-01 : Setup Project

text

```
TASK-001 | Setup Flutter project struktur folder
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 2 jam

Folder structure:
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── errors/
├── features/
│   ├── auth/
│   ├── habit/
│   ├── stats/
│   ├── ai/
│   └── settings/
├── shared/
│   ├── widgets/
│   └── models/
└── main.dart

DoD: Project bisa run tanpa error
```

text

```
TASK-002 | Setup Dependencies (pubspec.yaml)
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 1 jam

Dependencies:
- flutter_bloc
- go_router
- firebase_core
- firebase_auth
- cloud_firestore
- google_sign_in
- hive_flutter
- flutter_local_notifications
- fl_chart
- dio
- shared_preferences
- lottie
- table_calendar
- uuid
- intl

DoD: flutter pub get sukses, tidak ada conflict
```

text

```
TASK-003 | Setup Firebase Project
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 1 jam

Steps:
- Buat project di console.firebase.google.com
- Enable Authentication (Google)
- Enable Firestore
- Download google-services.json
- Taruh di android/app/

DoD: Firebase terhubung, app tidak crash saat launch
```

text

```
TASK-004 | Setup GoRouter
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 2 jam

Routes yang dibuat:
/ → SplashScreen
/onboarding → OnboardingScreen
/login → LoginScreen
/home → HomeScreen
/habit/add → AddHabitScreen
/habit/detail/:id → HabitDetailScreen
/stats → StatsScreen
/settings → SettingsScreen
/ai-settings → AISettingsScreen

DoD: Navigasi antar screen bisa jalan
```

text

```
TASK-005 | Setup Theme (Light & Dark)
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 3 jam

Yang dibuat:
- AppColors (primary, secondary, background, dll)
- AppTextStyles (heading, body, caption)
- AppTheme.light()
- AppTheme.dark()
- ThemeCubit untuk toggle

Warna Rekomendasi:
Primary    : #6C63FF (purple modern)
Secondary  : #FF6584
Background : #0D0D0D (dark) / #F8F9FA (light)
Card       : #1A1A2E (dark) / #FFFFFF (light)
Success    : #4CAF50
Warning    : #FFC107

DoD: Dark/light mode bisa toggle, tidak ada widget overflow
```

----------

### 📁 EPIC-02 : Authentication

text

```
TASK-006 | Buat AuthRepository
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 2 jam

Method:
- signInWithGoogle() → Future<UserModel>
- signOut() → Future<void>
- getCurrentUser() → UserModel?
- authStateChanges() → Stream<UserModel?>

DoD: Unit test pass, Google login berhasil di device
```

text

```
TASK-007 | Buat AuthBloc / AuthCubit
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 2 jam

States:
- AuthInitial
- AuthLoading
- AuthAuthenticated(user)
- AuthUnauthenticated
- AuthError(message)

Events:
- AuthCheckRequested
- GoogleSignInRequested
- SignOutRequested

DoD: State management auth berjalan benar
```

text

```
TASK-008 | Buat SplashScreen
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 2 jam

Logic:
- Cek auth state
- Kalau sudah login → /home
- Kalau belum pernah → /onboarding
- Kalau pernah login tapi logout → /login

UI:
 - UI tidak perlu karena sudah saya buat

DoD: Redirect benar sesuai kondisi
```

text

```
TASK-009 | Buat LoginScreen
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 3 jam

UI Elements:
- Ilustrasi / Lottie animation
- Tagline app
- Tombol "Continue with Google"
- Loading state saat proses login

DoD: Login Google berhasil, redirect ke home/onboarding
```

----------

### 📁 EPIC-03 : Onboarding

text

```
TASK-010 | Buat OnboardingScreen (3 halaman)
─────────────────────────────────────────────────
Status   : DONE
Priority : P0
Estimate : 4 jam

Halaman 1: "Track Your Habits"
  - Ilustrasi checklist
  - Deskripsi singkat

Halaman 2: "Stay Consistent"
  - Ilustrasi streak/fire
  - Deskripsi singkat

Halaman 3: "AI-Powered Insights"
  - Ilustrasi AI/robot
  - Deskripsi singkat
  - Tombol "Get Started"

Fitur:
- PageView dengan dot indicator
- Skip button
- Smooth page transition
- Hanya muncul 1x (simpan flag di SharedPreferences)

DoD: Onboarding tampil sekali, animasi smooth
```

----------

### 📁 EPIC-04 : Habit Management

text

```
TASK-011 | Buat HabitModel
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 1 jam

Model:
class HabitModel {
  String id
  String userId
  String title
  String description
  String category      // health, study, fitness, etc
  String icon          // emoji atau icon name
  Color color
  TimeOfDay reminderTime
  List<String> activeDays  // ['mon','tue',...]
  DateTime createdAt
  bool isActive
}

DoD: Model bisa serialisasi ke/dari JSON & Hive
```

text

```
TASK-012 | Buat HabitLogModel
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 1 jam

Model:
class HabitLogModel {
  String id
  String habitId
  DateTime date
  bool isCompleted
  String? note
}

DoD: Model bisa serialisasi ke/dari JSON & Hive
```

text

```
TASK-013 | Buat HabitRepository
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 3 jam

Method:
- addHabit(habit) → Future<void>
- updateHabit(habit) → Future<void>
- deleteHabit(id) → Future<void>
- getHabits(userId) → Stream<List<HabitModel>>
- logHabit(log) → Future<void>
- getLogsForDate(date) → Future<List<HabitLogModel>>
- getLogsForHabit(habitId) → Future<List<HabitLogModel>>

Storage: Hive (local) + Firestore (cloud, opsional sync)

DoD: CRUD berjalan, data persist setelah restart
```

text

```
TASK-014 | Buat HabitBloc
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 3 jam

States:
- HabitInitial
- HabitLoading
- HabitLoaded(habits, todayLogs)
- HabitError(message)

Events:
- LoadHabits
- AddHabit(habit)
- UpdateHabit(habit)
- DeleteHabit(id)
- ToggleHabitLog(habitId, date)

DoD: Semua event mengubah state dengan benar
```

text

```
TASK-015 | Buat AddHabitScreen
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 5 jam

Form Fields:
- Habit title (text field)
- Description (optional)
- Category picker (icon grid)
- Color picker
- Emoji/icon picker
- Active days selector (Mon-Sun toggle)
- Reminder time picker

Validasi:
- Title tidak boleh kosong
- Minimal 1 hari aktif

DoD: Habit tersimpan, muncul di home screen
```

text

```
TASK-016 | Buat HomeScreen (Daily View)
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 6 jam

Sections:
1. Header
   - Greeting ("Good Morning, Rafi!")
   - Tanggal hari ini
   - Avatar user

2. Progress Ring
   - Completion % hari ini
   - "X of Y habits done"

3. Habit List
   - Card per habit
   - Checkbox/toggle untuk mark done
   - Icon, warna, nama habit
   - Streak indicator

4. FAB (+ tambah habit)

5. Bottom Navigation
   - Home, Stats, AI, Settings

DoD: Habit tampil, bisa di-toggle, progress update real-time
```

----------

## 🏃 SPRINT 2 — Streak, Notif, UX (Week 3–4)

----------

text

```
TASK-017 | Implementasi Streak System
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 4 jam

Logic:
- Streak = hari berturut-turut habit di-complete
- Streak reset kalau skip 1 hari active day
- Longest streak = record terbaik

Method di HabitRepository:
- calculateStreak(habitId) → int
- getLongestStreak(habitId) → int

UI:
- Badge api 🔥 di habit card
- Nomor streak

DoD: Streak hitung benar, test berbagai skenario
```

text

```
TASK-018 | Buat HabitDetailScreen
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 4 jam

Sections:
- Header (nama, icon, warna)
- Current streak 🔥
- Longest streak
- Completion rate (%)
- Mini calendar (30 hari terakhir)
- Tombol Edit
- Tombol Delete (dengan konfirmasi)

DoD: Data akurat, delete konfirmasi sebelum hapus
```

text

```
TASK-019 | Implementasi Local Notification
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 5 jam

Library: flutter_local_notifications

Setup:
- Request permission Android 13+
- Scheduled notification per habit
- Notif muncul sesuai reminderTime
- Notif hanya di active days habit itu

NotificationService:
- scheduleHabitReminder(habit)
- cancelHabitReminder(habitId)
- cancelAllReminders()
- rescheduleAll(habits)

Notif content:
- Title: "Time for [Habit Name]! 💪"
- Body: "Keep your streak going! Don't break the chain."

DoD: Notif muncul di waktu yang benar, test di emulator
```

text

```
TASK-020 | Buat EditHabitScreen
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 3 jam

- Sama dengan AddHabitScreen
- Pre-fill data habit yang ada
- Setelah save → reschedule notification

DoD: Edit tersimpan benar, notif ikut update
```

text

```
TASK-021 | Implementasi Dark Mode Toggle
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 2 jam

- ThemeCubit dengan state light/dark
- Toggle di Settings screen
- Simpan preference di SharedPreferences
- App restart tetap ingat pilihan

DoD: Toggle smooth, semua screen consistent
```

text

```
TASK-022 | Animasi & Polish UI Sprint 2
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 4 jam

Animasi yang ditambah:
- Checkbox habit → checkmark animation
- Habit card → slide in saat load
- Completion ring → animated progress
- Streak badge → pulse animation saat streak naik
- FAB → scale animation

Library: flutter built-in AnimationController + Lottie

DoD: Tidak ada jank, 60fps di mid-range device
```

text

```
TASK-023 | Buat Calendar View
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 4 jam

Library: table_calendar

Fitur:
- Tampil di HabitDetailScreen atau tab tersendiri
- Tanggal dengan habit selesai → dot hijau
- Tanggal dengan habit skip → dot merah/abu
- Tap tanggal → lihat habit apa saja yang done

DoD: Calendar akurat sesuai log data
```

----------

## 🏃 SPRINT 3 — Statistik & Analytics (Week 5–6)

----------

text

```
TASK-024 | Buat StatsScreen (Overview)
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 5 jam

Sections:
1. Summary Cards
   - Total habits aktif
   - Best streak (semua habit)
   - Today completion %
   - This week completion %

2. Weekly Bar Chart
   - X: Senin–Minggu
   - Y: Jumlah habit selesai
   - Library: fl_chart

3. Habit Ranking
   - Habit paling konsisten (completion rate tinggi)
   - Habit paling sering skip

DoD: Data akurat, chart render tanpa error
```

text

```
TASK-025 | Buat Completion Rate Calculator
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 3 jam

Logic:
completionRate = (hari completed / hari aktif total) * 100

Per periode:
- 7 hari terakhir
- 30 hari terakhir
- All time

Tampilkan sebagai:
- Persentase
- Progress bar
- Warna: hijau >70%, kuning 40-70%, merah <40%

DoD: Kalkulasi benar, test dengan data dummy
```

text

```
TASK-026 | Buat Weekly Progress Chart
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 3 jam

Chart type: Bar Chart (fl_chart)
Data: Habits completed per day this week
Tambahan: Line chart completion rate 4 minggu

Styling:
- Sesuai tema app
- Tooltip saat tap bar
- Animasi saat chart muncul

DoD: Chart tampil benar, data dari repository
```

text

```
TASK-027 | Buat Category Analytics
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 3 jam

Chart type: Pie chart / Donut chart
Data: Distribusi habit per kategori
    (Health 30%, Study 20%, Fitness 50%, dll)

Tambahan:
- Kategori mana paling konsisten
- Kategori mana paling sering gagal

DoD: Pie chart akurat, interactive (tap slice)
```

text

```
TASK-028 | UI Polish Sprint 3
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 4 jam

Yang dipoles:
- Empty state screens (ilustrasi + teks)
- Error state screens
- Loading skeleton (shimmer effect)
- Smooth screen transitions
- Consistent spacing & typography

Library tambahan: shimmer

DoD: Tidak ada screen kosong tanpa feedback
```

text

```
TASK-029 | Buat SettingsScreen
─────────────────────────────────────────────────
Status   : TODO
Priority : P1
Estimate : 3 jam

Menu:
- Profile (foto, nama, email)
- Dark Mode toggle
- Notification on/off
- AI Settings (link ke AI setup)
- About App (versi, developer)
- Privacy Policy (webview/link)
- Logout (dengan konfirmasi)

DoD: Semua setting berfungsi dan tersimpan
```

----------

## 🏃 SPRINT 4 — AI Feature & Launch (Week 7–8)

----------

text

```
TASK-030 | Buat AISettingsScreen (BYOK)
─────────────────────────────────────────────────
Status   : TODO
Priority : P2
Estimate : 4 jam

UI:
- Penjelasan "Apa itu API key?"
- Link ke https://makersuite.google.com/app/apikey
- Text field untuk input API key
- Tombol "Test & Save"
- Status: Connected ✅ / Not Connected ❌
- Tombol hapus API key

Security:
- API key disimpan di SharedPreferences LOKAL
- Tidak pernah dikirim ke servermu
- Tampilkan peringatan: "Key tersimpan hanya di device ini"

DoD: API key tersimpan, bisa test koneksi
```

text

```
TASK-031 | Buat GeminiService
─────────────────────────────────────────────────
Status   : TODO
Priority : P2
Estimate : 4 jam

Class: GeminiService

Method:
- getMotivation(context) → Future<String>
- getInsight(habitData) → Future<String>
- testConnection(apiKey) → Future<bool>

API Call:
POST https://generativelanguage.googleapis.com/v1beta/
     models/gemini-pro:generateContent?key={USER_KEY}

Header: Content-Type: application/json

Body contoh:
{
  "contents": [{
    "parts": [{
      "text": "prompt di sini"
    }]
  }]
}

Error handling:
- Invalid API key → tampil pesan jelas
- Rate limit → tampil pesan + suggest tunggu
- No internet → offline fallback message

DoD: Call ke Gemini berhasil dengan user's key
```

text

```
TASK-032 | Buat Prompt Engineering untuk Motivasi
─────────────────────────────────────────────────
Status   : TODO
Priority : P2
Estimate : 3 jam

Prompt template:

"Kamu adalah AI coach untuk habit tracker.
Data user:
- Nama: {name}
- Habit aktif: {habitList}
- Streak terbaik hari ini: {bestStreak} hari
- Completion hari ini: {todayCompletion}%
- Completion minggu ini: {weekCompletion}%
- Habit paling konsisten: {bestHabit}
- Habit paling sering skip: {worstHabit}

Berikan 1 pesan motivasi personal dalam Bahasa Indonesia,
2-3 kalimat, positif, spesifik berdasarkan data di atas.
Jangan gunakan emoji berlebihan."

DoD: Response relevan, personal, tidak generic
```

text

```
TASK-033 | Buat AIScreen / AI Insight Screen
─────────────────────────────────────────────────
Status   : TODO
Priority : P2
Estimate : 5 jam

Sections:

1. Daily Motivation Card
   - Tombol "Get Today's Motivation"
   - Loading state (shimmer/lottie)
   - Tampil pesan AI
   - Tombol refresh

2. Smart Insights
   - "Jam produktifmu: 07.00 - 09.00"
   - "Habit yang sering skip: Baca Buku"
   - "Kamu paling konsisten di: Senin & Rabu"

3. Weekly Summary AI
   - Tombol "Generate Weekly Summary"
   - AI rangkum performa habit minggu ini

State jika belum setup API key:
   - Tampil ilustrasi + penjelasan
   - Tombol "Setup AI Key"

DoD: AI response tampil dengan baik, error handled
```

text

```
TASK-034 | Buat Smart Insight (Tanpa AI)
─────────────────────────────────────────────────
Status   : TODO
Priority : P2
Estimate : 3 jam

Insight yang dihitung LOKAL (tidak butuh API):

1. Hari paling produktif
   Hitung: completion rate per hari dalam seminggu
   Tampil: "Kamu paling konsisten di hari Senin 🎯"

2. Habit terkuat
   Hitung: completion rate tertinggi
   Tampil: "Habit terkuatmu: Olahraga (87%)"

3. Habit perlu perhatian
   Hitung: completion rate terendah
   Tampil: "Baca Buku perlu lebih diperhatikan (23%)"

4. Waktu favorit
   Berdasarkan reminder time yang paling sering di-complete

DoD: Insight muncul walau tanpa API key
```

text

```
TASK-035 | Buat Achievement Badge System
─────────────────────────────────────────────────
Status   : TODO
Priority : P2
Estimate : 4 jam

Badge List:
🔥 "First Flame"     - Complete habit pertama kali
⚡ "3-Day Warrior"   - Streak 3 hari
🏆 "Week Champion"   - Streak 7 hari
💎 "Month Master"    - Streak 30 hari
🎯 "Perfectionist"   - Complete semua habit 1 hari penuh
🌟 "Multi-Tasker"    - Punya 5+ habit aktif
🚀 "AI Explorer"     - Setup AI pertama kali

Logic:
- Cek kondisi badge setiap kali state berubah
- Tampil popup saat badge pertama kali unlock
- Simpan badge unlocked di Hive

DoD: Badge unlock sesuai kondisi, popup muncul 1x
```

text

```
TASK-036 | Play Store Asset Preparation
─────────────────────────────────────────────────
Status   : TODO
Priority : P0 (untuk launch)
Estimate : 6 jam

Yang harus dibuat:

1. App Icon
   - 512x512 px, format PNG
   - Foreground + background (adaptive icon)

2. Feature Graphic
   - 1024x500 px

3. Screenshots (min 4)
   - Home screen
   - Stats screen
   - AI screen
   - Dark mode screen
   - Ukuran: phone screenshot

4. Short Description (80 karakter)
   "Track habits daily with AI-powered insights & motivation"

5. Full Description (4000 karakter max)
   - Fitur utama
   - Cara kerja AI (BYOK explanation)
   - Privacy note

6. Privacy Policy URL
   - Buat halaman sederhana (bisa pakai GitHub Pages)
   - Isi: data apa yang dikumpulkan, bagaimana API key dikelola

DoD: Semua asset siap upload ke Play Console
```

text

```
TASK-037 | App Release Build & Sign
─────────────────────────────────────────────────
Status   : TODO
Priority : P0 (untuk launch)
Estimate : 3 jam

Steps:
1. Generate keystore
   keytool -genkey -v -keystore habitflow.keystore

2. Setup key.properties di android/

3. Update build.gradle untuk signing config

4. Build release APK/AAB
   flutter build appbundle --release

5. Test release build di device real

6. Upload ke Play Console
   - Internal testing dulu
   - Review 1-3 hari

DoD: AAB ter-upload, tidak crash di release mode
```

text

```
TASK-038 | Final QA & Bug Fix
─────────────────────────────────────────────────
Status   : TODO
Priority : P0
Estimate : 8 jam

Test Checklist:
□ Login / logout flow
□ Tambah, edit, delete habit
□ Toggle checklist harian
□ Streak hitung benar
□ Notifikasi muncul tepat waktu
□ Dark mode semua screen
□ AI feature dengan API key valid
□ AI feature tanpa API key (graceful)
□ Badge unlock trigger benar
□ Calendar view akurat
□ Chart data akurat
□ Offline mode (tanpa internet)
□ Tidak ada memory leak
□ Performance di low-end device

DoD: Semua checklist pass, tidak ada crash
```

----------

## 📊 RINGKASAN TIMELINE

text

```
SPRINT 1 (Week 1-2)  ████████░░░░░░░░
Tasks: 001-016
Deliverable: Login ✅ Habit CRUD ✅ Home Screen ✅

SPRINT 2 (Week 3-4)  ████████████████████░░░░
Tasks: 017-023
Deliverable: Streak ✅ Notif ✅ Calendar ✅ Dark Mode ✅

SPRINT 3 (Week 5-6)  ████████████████████████████░░░░
Tasks: 024-029
Deliverable: Stats ✅ Charts ✅ UI Polish ✅

SPRINT 4 (Week 7-8)  ████████████████████████████████████████
Tasks: 030-038
Deliverable: AI ✅ Badge ✅ Play Store Launch ✅
```

----------

## 🎯 DEFINITION OF DONE (Global)

text

```
Setiap task dianggap selesai jika:

✅ Fitur berjalan sesuai requirement
✅ Tidak ada error / crash
✅ UI sesuai tema (dark/light)
✅ Tidak ada hardcoded string (pakai constants)
✅ Error state ditangani (bukan blank screen)
✅ Loading state ada
✅ Test manual di emulator DAN device real
```

----------

> 💡  **Tips**: Fokus P0 dulu. Kalau P0 semua selesai dan masih ada waktu, baru P1 dan P2. Portfolio yang punya  **sedikit fitur tapi polish**  > banyak fitur tapi setengah jadi.
