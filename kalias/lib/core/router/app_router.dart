import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/room/room_screen.dart';
import '../../features/minigames/breathing/breathing_screen.dart';
import '../../features/minigames/eq_sort/eq_sort_screen.dart';
import '../../features/minigames/reading/reading_screen.dart';
import '../../features/minigames/math/math_screen.dart';
import '../../features/reward/reward_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const room = '/room';
  static const breathing = '/minigame/breathing';
  static const eqSort = '/minigame/eq-sort';
  static const reading = '/minigame/reading';
  static const math = '/minigame/math';
  static const reward = '/reward';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.room,
      builder: (context, state) => const RoomScreen(),
    ),
    GoRoute(
      path: AppRoutes.breathing,
      builder: (context, state) => const BreathingScreen(),
    ),
    GoRoute(
      path: AppRoutes.eqSort,
      builder: (context, state) => const EqSortScreen(),
    ),
    GoRoute(
      path: AppRoutes.reading,
      builder: (context, state) => const ReadingScreen(),
    ),
    GoRoute(
      path: AppRoutes.math,
      builder: (context, state) => const MathScreen(),
    ),
    GoRoute(
      path: AppRoutes.reward,
      builder: (context, state) => const RewardScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
