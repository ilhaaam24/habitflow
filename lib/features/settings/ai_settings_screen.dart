import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../shared/widgets/neobrutalist_button.dart';
import '../../shared/widgets/neobrutalist_card.dart';

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _prefs = GetIt.instance<SharedPreferences>();
  final _keyController = TextEditingController();
  bool _isSetupOpen = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _apiKey = _prefs.getString('gemini_api_key');
    if (_apiKey != null) {
      _keyController.text = _apiKey!;
    }
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
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await _prefs.setString('gemini_api_key', key);
    setState(() {
      _apiKey = key;
      _isSetupOpen = false;
    });
  }

  Future<void> _clearKey() async {
    await _prefs.remove('gemini_api_key');
    setState(() {
      _apiKey = null;
      _keyController.clear();
      _isSetupOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "AI COACH SETTINGS",
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Colors.black, height: 2, thickness: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: _apiKey == null ? _buildOfflineState() : _buildActiveState(),
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // EMPTY STATE 2 Robot container
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFC77DFF),
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Floating scattered ZzZ labels
                const Positioned(
                  top: 15,
                  right: 20,
                  child: Text(
                    'Z',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Positioned(
                  top: 35,
                  right: 45,
                  child: Text(
                    'z',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Positioned(
                  top: 50,
                  right: 65,
                  child: Text(
                    'z',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Robot face made of shapes
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        // Dot eyes
                        Positioned(
                          top: 24,
                          left: 14,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 24,
                          right: 14,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Rectangle mouth
                        Positioned(
                          bottom: 16,
                          left: 20,
                          child: Container(
                            width: 40,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "AI IS OFFLINE.",
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Connect your free Gemini API key\nto wake up your AI coach.",
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        if (!_isSetupOpen)
          NeobrutalistButton(
            color: const Color(0xFFC77DFF),
            onTap: () => setState(() => _isSetupOpen = true),
            child: const Text(
              "SETUP AI NOW →",
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          )
        else
          NeobrutalistCard(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ENTER GEMINI API KEY",
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "AIzaSy...",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFFFFFEF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NeobrutalistButton(
                        color: const Color(0xFF6BCB77),
                        onTap: _saveKey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text(
                            "SAVE KEY",
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeobrutalistButton(
                        color: const Color(0xFFFF6B6B),
                        onTap: () => setState(() => _isSetupOpen = false),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text(
                            "CANCEL",
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActiveState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeobrutalistCard(
          color: const Color(0xFF6BCB77),
          child: Row(
            children: [
              const Text(
                "🤖",
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "AI COACH IS AWAKE!",
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Gemini is fully connected and analyzing your discipline habits.",
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "DAILY INSIGHTS",
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        NeobrutalistCard(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Discipline beats motivation. You have completed 80% of your habits this week. Keep up the high consistency on fitness, but give learning some extra focus today!",
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.black, thickness: 1.5),
              SizedBox(height: 8),
              Text(
                "💡 TIP: Do your easiest habit first to build immediate momentum.",
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: Color(0xFFC77DFF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: NeobrutalistButton(
            color: const Color(0xFFFF6B6B),
            onTap: _clearKey,
            child: const Text(
              "DISCONNECT AI COACH",
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
