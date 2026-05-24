import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitFlow AI - Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your Daily Habits List'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/habit/add'),
              child: const Text('Add a New Habit'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.push('/habit/detail/123'),
              child: const Text('View Habit Detail (id: 123)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.push('/stats'),
              child: const Text('Go to Analytics/Stats'),
            ),
          ],
        ),
      ),
    );
  }
}
