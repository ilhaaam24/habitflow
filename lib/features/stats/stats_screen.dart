import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // 0: WEEK, 1: MONTH, 2: ALL TIME
  int _selectedPeriodIndex = 0;

  // Consistency & Streak data based on selected period
  final List<Map<String, dynamic>> _periodMetrics = [
    {'consistency': '92', 'total': '100', 'badge': 'TOP 8% 🏆', 'streak': '7'},
    {
      'consistency': '88',
      'total': '100',
      'badge': 'TOP 12% 🏆',
      'streak': '23',
    },
    {
      'consistency': '84',
      'total': '100',
      'badge': 'TOP 15% 🏆',
      'streak': '45',
    },
  ];

  // Daily heights for weekly bar chart (Fitness, Health, Learning)
  // Max count is 10, so proportional height out of 160px: count * 16px
  final List<List<double>> _weeklyData = [
    [5, 2.5, 7.5], // Mon
    [6.25, 3.75, 5.625], // Tue
    [3.125, 6.875, 4.375], // Wed
    [7.5, 1.875, 6.875], // Thu
    [5.625, 4.375, 8.125], // Fri
    [8.75, 7.5, 3.75], // Sat
    [6.875, 8.125, 8.75], // Sun
  ];

  // Ranking list data
  final List<Map<String, dynamic>> _rankingData = [
    {
      'rank': '01',
      'title': 'MORNING HYDRATION',
      'emoji': '💧',
      'color': 0xFF4D96FF, // blue
      'rate': 95,
    },
    {
      'rank': '02',
      'title': 'MEDITATION',
      'emoji': '🧘',
      'color': 0xFFFF6FC8, // pink
      'rate': 87,
    },
    {
      'rank': '03',
      'title': 'EVENING RUN',
      'emoji': '🏃',
      'color': 0xFFFF6B6B, // red
      'rate': 72,
    },
    {
      'rank': '04',
      'title': 'READING',
      'emoji': '📚',
      'color': 0xFFC77DFF, // purple
      'rate': 58,
    },
    {
      'rank': '05',
      'title': 'VITAMINS',
      'emoji': '💊',
      'color': 0xFFFFD93D, // yellow
      'rate': 31,
    },
  ];

  Widget _buildHeader() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: onSurface, width: 4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: onSurface, width: 3),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: onSurface,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '←',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ANALYTICS",
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -1,
                  color: onSurface,
                ),
              ),
              Text(
                "YOUR HABIT REPORT",
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 3,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Month Pill
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D),
              border: Border.all(color: onSurface, width: 2),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: onSurface,
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text("📅", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                const Text(
                  "NOV",
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: onSurface, width: 2),
      ),
      child: Row(
        children: [
          _buildPeriodTab(0, 'WEEK', onSurface, surfaceColor),
          Container(width: 2, color: onSurface),
          _buildPeriodTab(1, 'MONTH', onSurface, surfaceColor),
          Container(width: 2, color: onSurface),
          _buildPeriodTab(2, 'ALL TIME', onSurface, surfaceColor),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(
    int index,
    String label,
    Color onSurface,
    Color surfaceColor,
  ) {
    final isActive = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
          });
        },
        child: Container(
          color: isActive ? onSurface : surfaceColor,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
              color: isActive ? surfaceColor : onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigNumbersRow() {
    final metrics = _periodMetrics[_selectedPeriodIndex];
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left Block (Consistency)
          Expanded(
            child: Container(
              height: 156,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D),
                border: Border(
                  top: BorderSide(color: onSurface, width: 3),
                  bottom: BorderSide(color: onSurface, width: 3),
                  left: BorderSide(color: onSurface, width: 3),
                  right: BorderSide(color: onSurface, width: 2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "CONSISTENCY",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        metrics['consistency'] as String,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 56,
                          height: 1.0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '/${metrics['total']}',
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      metrics['badge'] as String,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Color(0xFFFFD93D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Block (Best Streak)
          Expanded(
            child: Container(
              height: 156,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                border: Border(
                  top: BorderSide(color: onSurface, width: 3),
                  bottom: BorderSide(color: onSurface, width: 3),
                  left: BorderSide(color: onSurface, width: 2),
                  right: BorderSide(color: onSurface, width: 3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "BEST STREAK",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 4),
                      Text(
                        metrics['streak'] as String,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 56,
                          height: 1.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: const Text(
                      "DAYS IN A ROW",
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: onSurface, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: onSurface,
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  "THIS WEEK",
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                    color: onSurface,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildLegendDot(
                      const Color(0xFFFFD93D),
                      "Fitness",
                      onSurface,
                    ),
                    const SizedBox(width: 8),
                    _buildLegendDot(
                      const Color(0xFFFF6B6B),
                      "Health",
                      onSurface,
                    ),
                    const SizedBox(width: 8),
                    _buildLegendDot(
                      const Color(0xFF6BCB77),
                      "Learning",
                      onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 2, color: onSurface),
          // Chart Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      // Y-axis labels and grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGridLine('10', onSurface),
                          _buildGridLine('5', onSurface),
                          _buildGridLine('0', onSurface),
                        ],
                      ),
                      // Bars
                      Positioned.fill(
                        left: 28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            return _buildDayBarGroup(index, onSurface);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label, Color onSurface) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: onSurface, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGridLine(String label, Color onSurface) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 2, color: onSurface.withValues(alpha: 0.2)),
        ),
      ],
    );
  }

  Widget _buildDayBarGroup(int index, Color onSurface) {
    final days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    final data = _weeklyData[index];

    // Scale height: count * 16px (max is 10, mapping to 160px)
    final h1 = data[0] * 16.0;
    final h2 = data[1] * 16.0;
    final h3 = data[2] * 16.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(h1, const Color(0xFFFFD93D), onSurface),
            const SizedBox(width: 2),
            _buildBar(h2, const Color(0xFFFF6B6B), onSurface),
            const SizedBox(width: 2),
            _buildBar(h3, const Color(0xFF6BCB77), onSurface),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          days[index],
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1,
            color: onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double height, Color color, Color onSurface) {
    return Container(
      width: 12,
      height: height.clamp(4.0, 160.0),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: onSurface, width: 2),
      ),
    );
  }

  Widget _buildHabitRankingTable() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: onSurface, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: onSurface,
            offset: const Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "HABIT RANKINGS",
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
                color: onSurface,
              ),
            ),
          ),
          Container(height: 2, color: onSurface),
          // Rows
          ...List.generate(_rankingData.length, (index) {
            final data = _rankingData[index];
            final rank = data['rank'] as String;
            final title = data['title'] as String;
            final emoji = data['emoji'] as String;
            final color = Color(data['color'] as int);
            final rate = data['rate'] as int;

            // Determine badge background color
            Color badgeBg;
            if (rate > 80) {
              badgeBg = const Color(0xFF6BCB77);
            } else if (rate > 50) {
              badgeBg = const Color(0xFFFFD93D);
            } else {
              badgeBg = const Color(0xFFFF6B6B);
            }

            final isLast = index == _rankingData.length - 1;

            return Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: onSurface, width: 2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Rank number
                  SizedBox(
                    width: 32,
                    child: Text(
                      rank,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: onSurface,
                      ),
                    ),
                  ),
                  // Emoji container
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: onSurface, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title & Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Custom Neobrutalist Progress Bar
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            border: Border.all(color: onSurface, width: 1.5),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: rate / 100.0,
                            heightFactor: 1.0,
                            child: Container(color: onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Rate Badge
                  Container(
                    decoration: BoxDecoration(
                      color: badgeBg,
                      border: Border.all(color: onSurface, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      "$rate%",
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStreakGrid() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: onSurface, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: onSurface,
            offset: const Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STREAK HISTORY",
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 2, color: onSurface),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(52, (colIndex) {
                return Column(
                  children: List.generate(7, (rowIndex) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: _getStreakCellColor(
                          colIndex,
                          rowIndex,
                          onSurface,
                          surfaceColor,
                        ),
                        border: Border.all(color: onSurface, width: 1),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStreakCellColor(
    int colIndex,
    int rowIndex,
    Color onSurface,
    Color surfaceColor,
  ) {
    final int hash =
        (colIndex * 3 + rowIndex * 7 + _selectedPeriodIndex * 13) % 11;
    if (hash < 4) {
      return surfaceColor;
    } else if (hash < 7) {
      return const Color(0xFFFFD93D).withValues(alpha: 0.3);
    } else if (hash < 10) {
      return const Color(0xFFFFD93D).withValues(alpha: 0.7);
    } else {
      return onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    _buildBigNumbersRow(),
                    _buildWeeklyBarChart(),
                    _buildHabitRankingTable(),
                    _buildStreakGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
