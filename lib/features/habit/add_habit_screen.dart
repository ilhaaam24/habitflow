import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/shared/models/habit_model.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_bloc.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_event.dart';
import 'package:habit_flow/features/habit/presentation/bloc/habit_state.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:habit_flow/features/auth/presentation/bloc/auth_state.dart';

class AddHabitScreen extends StatefulWidget {
  final String? habitId;
  const AddHabitScreen({super.key, this.habitId});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = '🏋️';
  bool _isPickingIcon = false;
  String _selectedCategory = '🏃 FITNESS';
  int _selectedColorValue = 0xFFFFD93D; // Yellow default
  final Set<String> _activeDays = {
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  };

  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabitData();
    }
  }

  void _loadHabitData() {
    final state = context.read<HabitBloc>().state;
    HabitModel? habit;

    if (widget.habitId!.startsWith('dummy_')) {
      final List<Map<String, dynamic>> dummyHabits = [
        {
          'id': 'dummy_1',
          'title': 'MORNING MEDITATION',
          'category': '🧘 MIND',
          'emoji': '🧘',
          'color': 0xFFC77DFF,
          'reminderTime': '07:00',
        },
        {
          'id': 'dummy_2',
          'title': 'EVENING RUN',
          'category': '🏃 FITNESS',
          'emoji': '🏃',
          'color': 0xFFFF6B6B,
          'reminderTime': '19:00',
        },
        {
          'id': 'dummy_3',
          'title': 'READ BOOK',
          'category': '📚 LEARNING',
          'emoji': '📚',
          'color': 0xFF4D96FF,
          'reminderTime': '21:00',
        },
      ];
      final dummyData = dummyHabits.firstWhere(
        (h) => h['id'] == widget.habitId,
        orElse: () => dummyHabits[1],
      );
      habit = HabitModel(
        id: dummyData['id'] as String,
        userId: 'dummy_user',
        title: dummyData['title'] as String,
        description: 'Mock habit description',
        category: dummyData['category'] as String,
        icon: dummyData['emoji'] as String,
        colorValue: dummyData['color'] as int,
        reminderTime: dummyData['reminderTime'] as String,
        activeDays: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        createdAt: DateTime.now().subtract(const Duration(days: 29)),
        isActive: true,
      );
    } else if (state is HabitLoaded) {
      habit = state.habits.where((h) => h.id == widget.habitId).firstOrNull;
    }

    if (habit != null) {
      _nameController.text = habit.title;
      _selectedIcon = habit.icon;
      _selectedCategory = habit.category;
      _selectedColorValue = habit.colorValue;
      _activeDays.clear();
      _activeDays.addAll(habit.activeDays);
      
      final parts = habit.reminderTime.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 8;
        final m = int.tryParse(parts[1]) ?? 0;
        _reminderTime = TimeOfDay(hour: h, minute: m);
      }
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'FITNESS', 'emoji': '🏃', 'color': 0xFFFFD93D},
    {'name': 'LEARNING', 'emoji': '📚', 'color': 0xFFC77DFF},
    {'name': 'HEALTH', 'emoji': '💧', 'color': 0xFF6BEBFF},
    {'name': 'MIND', 'emoji': '🧘', 'color': 0xFFFF6B6B},
    {'name': 'WORK', 'emoji': '💼', 'color': 0xFFFFB347},
    {'name': 'CREATE', 'emoji': '🎨', 'color': 0xFFFF85A2},
    {'name': 'MONEY', 'emoji': '💰', 'color': 0xFF6BCB77},
    {'name': 'SLEEP', 'emoji': '😴', 'color': 0xFF4D96FF},
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Yellow', 'value': 0xFFFFD93D},
    {'name': 'Red', 'value': 0xFFFF6B6B},
    {'name': 'Green', 'value': 0xFF6BCB77},
    {'name': 'Blue', 'value': 0xFF4D96FF},
    {'name': 'Pink', 'value': 0xFFFF85A2},
    {'name': 'Purple', 'value': 0xFFC77DFF},
    {'name': 'Orange', 'value': 0xFFFFB347},
    {'name': 'White', 'value': 0xFFFFFFFF},
  ];

  final List<Map<String, String>> _daysOfWeek = [
    {'key': 'mon', 'label': 'M'},
    {'key': 'tue', 'label': 'T'},
    {'key': 'wed', 'label': 'W'},
    {'key': 'thu', 'label': 'T'},
    {'key': 'fri', 'label': 'F'},
    {'key': 'sat', 'label': 'S'},
    {'key': 'sun', 'label': 'S'},
  ];

  final List<String> _emojiSelection = [
    '🏋️',
    '📚',
    '💧',
    '🧘',
    '💼',
    '🎨',
    '💰',
    '😴',
    '🏃',
    '🚶',
    '🍎',
    '🥑',
    '🥛',
    '🚴',
    '🏊',
    '🎹',
    '📝',
    '💻',
    '🌱',
    '🧹',
    '🔥',
    '🔋',
    '🎯',
    '❤️',
    '🐶',
    '😸',
    '🍳',
    '🍵',
    '🚶‍♂️',
    '✈️',
    '☀️',
    '⏰',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Color(0xFFFFFEF0),
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFFFFFEF0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _submitForm(String userId) {
    if (!_formKey.currentState!.validate()) return;
    if (_activeDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Text(
              'CHOOSE AT LEAST ONE REPEAT DAY!',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
      return;
    }

    final reminderStr =
        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

    if (widget.habitId != null && !widget.habitId!.startsWith('dummy_')) {
      final state = context.read<HabitBloc>().state;
      DateTime createdAt = DateTime.now();
      bool isActive = true;
      if (state is HabitLoaded) {
        final original = state.habits.where((h) => h.id == widget.habitId).firstOrNull;
        if (original != null) {
          createdAt = original.createdAt;
          isActive = original.isActive;
        }
      }
      final updatedHabit = HabitModel(
        id: widget.habitId!,
        userId: userId,
        title: _nameController.text.trim(),
        description: '',
        category: _selectedCategory,
        icon: _selectedIcon,
        colorValue: _selectedColorValue,
        reminderTime: reminderStr,
        activeDays: _activeDays.toList(),
        createdAt: createdAt,
        isActive: isActive,
      );
      context.read<HabitBloc>().add(UpdateHabitRequested(updatedHabit));
    } else {
      final newHabit = HabitModel(
        id: widget.habitId != null ? widget.habitId! : const Uuid().v4(),
        userId: userId,
        title: _nameController.text.trim(),
        description: '',
        category: _selectedCategory,
        icon: _selectedIcon,
        colorValue: _selectedColorValue,
        reminderTime: reminderStr,
        activeDays: _activeDays.toList(),
        createdAt: DateTime.now(),
        isActive: true,
      );
      context.read<HabitBloc>().add(AddHabitRequested(newHabit));
    }
    context.pop();
  }

  Widget _buildSectionLabel({required String text, required Color bgColor}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 2,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String userId = authState is AuthAuthenticated
        ? authState.user.uid
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF0),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '←',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.habitId != null ? 'EDIT HABIT' : 'NEW HABIT',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // Header Save check button
                    GestureDetector(
                      onTap: () => _submitForm(userId),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6BCB77),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: IDENTITY
                      _buildSectionLabel(
                        text: '01 — IDENTITY',
                        bgColor: const Color(0xFFFFD93D),
                      ),
                      const SizedBox(height: 24),

                      // Icon Picker Row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPickingIcon = !_isPickingIcon;
                              });
                            },
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD93D),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(6, 6),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _selectedIcon,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPickingIcon = !_isPickingIcon;
                                });
                              },
                              child: Container(
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'TAP TO CHOOSE ICON',
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                      color: Colors.black,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Emoji Grid
                      if (_isPickingIcon) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: _emojiSelection.length,
                            itemBuilder: (context, index) {
                              final emoji = _emojiSelection[index];
                              final isSelected = _selectedIcon == emoji;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIcon = emoji;
                                    _isPickingIcon = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFD93D)
                                        : Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: isSelected
                                        ? const [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(2, 2),
                                              blurRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Habit Name Textfield
                      const Text(
                        'HABIT NAME *',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          cursorColor: Colors.black,
                          cursorWidth: 3,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          maxLength: 30,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '  Please enter a habit name';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            fillColor: AppColors.white,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'e.g. Morning Run',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_nameController.text.length}/30',
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // SECTION 2: CATEGORY
                      _buildSectionLabel(
                        text: '02 — CATEGORY',
                        bgColor: const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(height: 24),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _categories.map((cat) {
                          final String catName = cat['name'] as String;
                          final String catEmoji = cat['emoji'] as String;
                          final int catColor = cat['color'] as int;
                          final String fullCatName = '$catEmoji $catName';
                          final isSelected = _selectedCategory == fullCatName;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = fullCatName;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(catColor)
                                    : Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: isSelected
                                        ? const Offset(3, 3)
                                        : const Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    catEmoji,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    catName,
                                    style: const TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // SECTION 3: COLOR
                      _buildSectionLabel(
                        text: '03 — COLOR',
                        bgColor: const Color(0xFFC77DFF),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _colors.map((color) {
                          final int val = color['value'] as int;
                          final isSelected = _selectedColorValue == val;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorValue = val;
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(val),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(4, 4),
                                          blurRadius: 0,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // SECTION 4: SCHEDULE
                      _buildSectionLabel(
                        text: '04 — SCHEDULE',
                        bgColor: const Color(0xFF4D96FF),
                      ),
                      const SizedBox(height: 24),

                      // Days Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _daysOfWeek.map((day) {
                          final key = day['key']!;
                          final label = day['label']!;
                          final isSelected = _activeDays.contains(key);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _activeDays.remove(key);
                                } else {
                                  _activeDays.add(key);
                                }
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFD93D)
                                    : Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(3, 3),
                                          blurRadius: 0,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.black38,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Daily Reminder Toggle Row
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _isReminderEnabled ? _selectTime : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD93D),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🔔',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _isReminderEnabled ? _selectTime : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DAILY REMINDER',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(_reminderTime),
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        color: _isReminderEnabled
                                            ? Colors.black
                                            : Colors.black38,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Custom Neobrutalism Toggle Switch
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isReminderEnabled = !_isReminderEnabled;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _isReminderEnabled
                                      ? Colors.black
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: _isReminderEnabled
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: _isReminderEnabled
                                            ? const Color(0xFFFFD93D)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                          color: _isReminderEnabled
                                              ? Colors.black
                                              : Colors.black45,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // CREATE HABIT Button
                      Container(
                        width: double.infinity,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6BCB77), // Green
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(6, 6),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _submitForm(userId),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'CREATE HABIT',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '→',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
