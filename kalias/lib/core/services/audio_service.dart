/// Audio service — wraps flame_audio.
///
/// All methods are safe to call even when audio files don't exist yet:
/// missing files are caught and silently ignored so the app never crashes
/// due to a missing asset. Add actual files to assets/audio/ to activate.
library;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Asset path constants ──────────────────────────────────────────────────────

abstract final class AudioAssets {
  // BGM — looping background tracks
  static const roomBgm  = 'music/room_bgm.mp3';
  static const calmBgm  = 'music/calm_bgm.mp3';

  // SFX — one-shot sound effects
  static const feed     = 'sfx/feed.mp3';
  static const play     = 'sfx/play.mp3';
  static const pop      = 'sfx/pop.mp3';
  static const success  = 'sfx/success.mp3';
  static const trunkOpen = 'sfx/trunk_open.mp3';
  static const breatheIn  = 'sfx/breathe_in.mp3';
  static const breatheOut = 'sfx/breathe_out.mp3';
}

// ── Service ───────────────────────────────────────────────────────────────────

class AudioService extends ChangeNotifier {
  bool _muted = false;
  bool get isMuted => _muted;

  /// Initialize flame_audio BGM controller. Call once at app startup.
  Future<void> initialize() async {
    try {
      FlameAudio.bgm.initialize();
    } catch (_) {}
  }

  void toggleMute() {
    _muted = !_muted;
    if (_muted) stopBgm();
    notifyListeners();
  }

  Future<void> playBgm(String assetName, {double volume = 0.35}) async {
    if (_muted) return;
    try {
      await FlameAudio.bgm.play(assetName, volume: volume);
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {}
  }

  Future<void> playSfx(String assetName, {double volume = 0.7}) async {
    if (_muted) return;
    try {
      await FlameAudio.play(assetName, volume: volume);
    } catch (_) {}
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final audioServiceProvider = ChangeNotifierProvider<AudioService>(
  (ref) => AudioService(),
);
