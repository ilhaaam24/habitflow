import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui';

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _prefs = GetIt.instance<SharedPreferences>();
  final _keyController = TextEditingController();
  String? _apiKey;
  bool _obscureText = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _apiKey = _prefs.getString('gemini_api_key');
    if (_apiKey != null) {
      _keyController.text = _apiKey!;
    }
    _keyController.addListener(() {
      setState(() {}); // dynamically update character counter on type
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key cannot be empty!'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    setState(() {
      _isTesting = true;
    });

    // Simulate key validation/testing loader
    await Future.delayed(const Duration(milliseconds: 1000));

    await _prefs.setString('gemini_api_key', key);
    if (mounted) {
      setState(() {
        _apiKey = key;
        _isTesting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key tested and saved successfully! 🤖'),
          backgroundColor: Color(0xFF6BCB77),
        ),
      );
    }
  }

  Future<void> _clearKey() async {
    await _prefs.remove('gemini_api_key');
    setState(() {
      _apiKey = null;
      _keyController.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key removed successfully.'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBanner(),
                    _buildSectionLabel(text: "HOW IT WORKS", bgColor: const Color(0xFFFFD93D)),
                    _buildStepCard(
                      number: "01",
                      color: const Color(0xFFFFD93D),
                      title: "GET FREE API KEY",
                      subtitle: "Visit Google AI Studio. Generate your free Gemini key.",
                    ),
                    _buildStepCard(
                      number: "02",
                      color: const Color(0xFFFF6B6B),
                      title: "PASTE KEY SECURELY",
                      subtitle: "Enter the key into the secure input form below.",
                    ),
                    _buildStepCard(
                      number: "03",
                      color: const Color(0xFF6BCB77),
                      title: "ACTIVATE COACH",
                      subtitle: "Test and save your key to unlock behavioral tracking.",
                    ),
                    _buildGetKeyButton(),
                    _buildApiKeyInput(),
                    _buildPrivacyNote(),
                    _buildActionButtons(),
                    _buildWhatYouUnlock(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  "←",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const Text(
            "AI SETUP",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 32), // Balance spacing
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final isConnected = _apiKey != null;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFF6BCB77) : const Color(0xFFFF6B6B),
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                isConnected ? "✓" : "!",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? "CONNECTED" : "NOT CONNECTED",
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected
                      ? "Your Gemini API key is active"
                      : "Add your API key to unlock AI",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel({required String text, Color bgColor = const Color(0xFFFFD93D)}) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
              color: bgColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 3,
                color: bgColor == Colors.black ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
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
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetKeyButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Google AI Studio (makersuite.google.com)... 🌐'),
            backgroundColor: Color(0xFFFFD93D),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              "🔗",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "GET YOUR FREE API KEY",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "makersuite.google.com →",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D),
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  "↗",
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
    );
  }

  Widget _buildApiKeyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 4),
          child: Text(
            "YOUR API KEY",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(5, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _keyController,
                  obscureText: _obscureText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: "AIzaSyXXXXXXXXXXXXXXXXXXXXX",
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontFamily: 'monospace',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                thickness: 2,
                height: 2,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "SHOW / HIDE KEY",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${_keyController.text.length} CHARS",
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      child: CustomPaint(
        painter: DashedRectanglePainter(
          color: Colors.black,
          strokeWidth: 2.0,
          gap: 4.0,
          dashLength: 6.0,
          borderRadius: 6.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x4DFFD93D), // yellow 30%
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                "🔒",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "STORED ONLY ON YOUR DEVICE. WE NEVER SEE YOUR KEY.",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isConnected = _apiKey != null;
    return Column(
      children: [
        GestureDetector(
          onTap: _isTesting ? null : _saveKey,
          child: Container(
            margin: const EdgeInsets.all(16),
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6BCB77), // green
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isTesting
                  ? null
                  : const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                _isTesting ? "TESTING KEY..." : "TEST & SAVE KEY →",
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        if (isConnected)
          GestureDetector(
            onTap: _clearKey,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(8),
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
                  "✕ REMOVE API KEY",
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWhatYouUnlock() {
    final List<String> items = [
      "DAILY AI MOTIVATION",
      "BRUTALLY HONEST COACHING",
      "WEEKLY PROGRESS REPORTS",
      "BEHAVIORAL PATTERN ANALYSIS",
    ];

    return Column(
      children: [
        _buildSectionLabel(text: "YOU'LL UNLOCK", bgColor: Colors.black),
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD93D),
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              "✓",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          items[index],
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 1,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class DashedRectanglePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedRectanglePainter({
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : gap;
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
