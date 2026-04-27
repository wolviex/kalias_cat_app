import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoomTimeOfDay { morning, afternoon, dusk, night }

enum MotionLevel { minimal, moderate, lots }

class RoomState {
  final RoomTimeOfDay timeOfDay;
  final MotionLevel motion;
  final bool showChrome;

  const RoomState({
    this.timeOfDay = RoomTimeOfDay.afternoon,
    this.motion = MotionLevel.moderate,
    this.showChrome = true,
  });

  bool get isNight => timeOfDay == RoomTimeOfDay.night;

  String get timeLabel => switch (timeOfDay) {
        RoomTimeOfDay.morning => 'morning',
        RoomTimeOfDay.afternoon => 'afternoon',
        RoomTimeOfDay.dusk => 'golden hour',
        RoomTimeOfDay.night => 'night',
      };

  RoomState copyWith({
    RoomTimeOfDay? timeOfDay,
    MotionLevel? motion,
    bool? showChrome,
  }) =>
      RoomState(
        timeOfDay: timeOfDay ?? this.timeOfDay,
        motion: motion ?? this.motion,
        showChrome: showChrome ?? this.showChrome,
      );
}

class RoomNotifier extends Notifier<RoomState> {
  @override
  RoomState build() => RoomState(timeOfDay: _timeOfDayFromClock());

  static RoomTimeOfDay _timeOfDayFromClock() {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 11) return RoomTimeOfDay.morning;
    if (h >= 11 && h < 17) return RoomTimeOfDay.afternoon;
    if (h >= 17 && h < 20) return RoomTimeOfDay.dusk;
    return RoomTimeOfDay.night;
  }
}

final roomProvider =
    NotifierProvider<RoomNotifier, RoomState>(RoomNotifier.new);

/// Which character (if any) currently has the care sheet open.
/// Values: null | 'noodles' | 'loafCat' | 'robotCat' | 'kalia'
final focusedCatProvider = StateProvider<String?>((ref) => null);
