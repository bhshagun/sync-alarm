import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../screens/alarm_ring_screen.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _checkTimer;
  List<AlarmModel> _activeAlarms = [];
  final Set<String> _triggeredToday = {};
  GlobalKey<NavigatorState>? navigatorKey;

  void init(GlobalKey<NavigatorState> navKey) {
    navigatorKey = navKey;
    _startTimer();
  }

  void updateAlarms(List<AlarmModel> alarms) {
    _activeAlarms = alarms.where((a) => a.isEnabled).toList();
  }

  void _startTimer() {
    _checkTimer?.cancel();
    // Check every 10 seconds for exact minute match
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkTrigger();
    });
  }

  void _checkTrigger() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Mon, ..., 7 = Sun
    final keyPrefix = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';

    for (final alarm in _activeAlarms) {
      final matchesMinute = alarm.hour == now.hour && alarm.minute == now.minute;
      final matchesDay = alarm.repeatDays.isEmpty || alarm.repeatDays.contains(currentWeekday);
      final triggerKey = '$keyPrefix-${alarm.id}';

      if (matchesMinute && matchesDay && !_triggeredToday.contains(triggerKey)) {
        _triggeredToday.add(triggerKey);
        _ring(alarm);
        break;
      }
    }
  }

  Future<void> _ring(AlarmModel alarm) async {
    try {
      // Loop ringing sound
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Play a pleasant wake up chime / alarm sound online URL as fallback or local asset
      await _audioPlayer.play(
        UrlSource('https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg'),
      );
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }

    if (navigatorKey?.currentContext != null) {
      Navigator.of(navigatorKey!.currentContext!).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => AlarmRingScreen(alarm: alarm),
        ),
      );
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
  }

  void snooze(AlarmModel alarm, int minutes) {
    stop();
    final now = DateTime.now().add(Duration(minutes: minutes));
    final snoozed = alarm.copyWith(
      id: 'snooze-${DateTime.now().millisecondsSinceEpoch}',
      hour: now.hour,
      minute: now.minute,
      title: 'Snoozed: ${alarm.title}',
      repeatDays: [],
    );
    _activeAlarms.add(snoozed);
  }

  void dispose() {
    _checkTimer?.cancel();
    _audioPlayer.dispose();
  }
}
