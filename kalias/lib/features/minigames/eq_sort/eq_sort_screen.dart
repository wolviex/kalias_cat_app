import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class EqSortScreen extends StatelessWidget {
  const EqSortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feelings Sort')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😊 EQ Sort minigame coming in Phase 2'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.reward),
              child: const Text('Finish (stub)'),
            ),
          ],
        ),
      ),
    );
  }
}
