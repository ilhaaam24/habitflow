import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'HabitFlow AI',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/onboarding'),
              child: const Text('Go to Onboarding'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home (bypass auth)'),
            ),
          ],
        ),
      ),
    );
  }
}
