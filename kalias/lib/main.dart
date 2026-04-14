import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/models/player_profile.dart';
import 'core/router/app_router.dart';
import 'core/services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PlayerProfileAdapter());
  await Hive.openBox<PlayerProfile>('player_profile');
  await Hive.openBox('cat_states'); // untyped box — stores hunger/energy ints + savedAt string

  // Initialise flame_audio BGM controller (safe no-op if audio files absent)
  await AudioService().initialize();

  runApp(const ProviderScope(child: KaliasApp()));
}

class KaliasApp extends StatelessWidget {
  const KaliasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Kalia's Cat App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
