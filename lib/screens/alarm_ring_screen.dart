import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/supabase_service.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmModel alarm;
  const AlarmRingScreen({Key? key, required this.alarm}) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  final SupabaseService _supabase = SupabaseService();
  final AlarmService _alarmService = AlarmService();

  bool _hasLocalUserTappedOff = false;
  bool _isBothDismissed = false;
  StreamSubscription<AlarmModel?>? _alarmSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _listenToDismissals();
  }

  void _listenToDismissals() {
    _alarmSubscription = _supabase.streamSingleAlarm(widget.alarm.id).listen((updated) {
      if (updated == null) return;

      final myName = _supabase.userName ?? 'Me';
      final hasTapped = updated.dismissedBy.contains(myName);
      final count = updated.dismissedBy.length;

      if (mounted) {
        setState(() {
          if (hasTapped) _hasLocalUserTappedOff = true;
          // Both turned off!
          if (count >= 2 || (!updated.requireBothToDismiss && count >= 1)) {
            _isBothDismissed = true;
          }
        });

        if (_isBothDismissed) {
          _finishDismissal();
        }
      }
    });
  }

  Future<void> _handleTurnOff() async {
    final myName = _supabase.userName ?? 'Me';

    if (!widget.alarm.requireBothToDismiss) {
      // Single dismiss allowed
      _alarmService.stop();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _hasLocalUserTappedOff = true);
    await _supabase.markAlarmDismissed(widget.alarm.id, myName);
  }

  Future<void> _finishDismissal() async {
    _alarmService.stop();
    // Reset dismissal record for next scheduled time
    await _supabase.resetAlarmDismissed(widget.alarm.id);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _snooze(int minutes) {
    _alarmService.snooze(widget.alarm, minutes);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myName = _supabase.userName ?? 'Me';

    return WillPopScope(
      onWillPop: () async => false, // Prevent physical back button escape
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isBothDismissed
                  ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                  : _hasLocalUserTappedOff
                      ? [const Color(0xFF1E1B2E), const Color(0xFF2E0854)]
                      : [const Color(0xFF380036), const Color(0xFFFF5E7E), const Color(0xFFFF9966)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Top Header / Time
                Column(
                  children: [
                    Text(
                      _isBothDismissed
                          ? 'BOTH AWAKE!'
                          : widget.alarm.requireBothToDismiss
                              ? 'DUAL-WAKE ALARM'
                              : 'ALARM RINGING',
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.alarm.formattedTime,
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),

                // Center Icon with Heart Pulse
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      boxShadow: [
                        BoxShadow(
                          color: (_isBothDismissed ? Colors.greenAccent : const Color(0xFFFF5E7E)).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isBothDismissed
                          ? Icons.check_circle_rounded
                          : _hasLocalUserTappedOff
                              ? Icons.hourglass_top_rounded
                              : Icons.favorite_rounded,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Title & Partner Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        widget.alarm.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set by ${widget.alarm.createdByName} ❤️',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dual Wake-Up Status Badge
                if (widget.alarm.requireBothToDismiss)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isBothDismissed
                            ? Colors.greenAccent
                            : _hasLocalUserTappedOff
                                ? Colors.amber
                                : Colors.white24,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isBothDismissed
                                  ? Icons.done_all
                                  : _hasLocalUserTappedOff
                                      ? Icons.hourglass_bottom
                                      : Icons.lock_clock,
                              color: _isBothDismissed
                                  ? Colors.greenAccent
                                  : _hasLocalUserTappedOff
                                      ? Colors.amber
                                      : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isBothDismissed
                                  ? '2/2 Turned Off - Alarm Stopped! 🎉'
                                  : _hasLocalUserTappedOff
                                      ? '1/2 Turned Off - Waiting for Partner...'
                                      : 'Both of you must tap Turn Off to stop!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isBothDismissed
                                    ? Colors.greenAccent
                                    : _hasLocalUserTappedOff
                                        ? Colors.amber
                                        : Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (_hasLocalUserTappedOff && !_isBothDismissed) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'You confirmed awake! The alarm is still ringing on her phone until she turns it off too ❤️',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isBothDismissed
                      ? const Text(
                          'Have a wonderful day together! ☀️❤️',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _snooze(5),
                                icon: const Icon(Icons.snooze, color: Colors.white),
                                label: const Text('Snooze (5m)', style: TextStyle(color: Colors.white, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.18),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _hasLocalUserTappedOff ? null : _handleTurnOff,
                                icon: Icon(
                                  _hasLocalUserTappedOff ? Icons.check : Icons.alarm_off,
                                  color: _hasLocalUserTappedOff ? Colors.white38 : const Color(0xFF2E0854),
                                ),
                                label: Text(
                                  _hasLocalUserTappedOff ? 'Waiting...' : 'Turn Off Alarm',
                                  style: TextStyle(
                                    color: _hasLocalUserTappedOff ? Colors.white38 : const Color(0xFF2E0854),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasLocalUserTappedOff ? Colors.white12 : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
