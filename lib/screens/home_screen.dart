import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/supabase_service.dart';
import 'add_alarm_screen.dart';
import 'pairing_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabase = SupabaseService();
  final AlarmService _alarmService = AlarmService();

  @override
  Widget build(BuildContext context) {
    final pairCode = _supabase.pairCode ?? 'NOT PAIRED';

    return Scaffold(
      backgroundColor: const Color(0xFF13111C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Color(0xFFFF5E7E), size: 22),
            const SizedBox(width: 8),
            Text(
              'SyncAlarm',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Couple Pairing Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF5E7E).withOpacity(0.2),
                    const Color(0xFF6C5CE7).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF5E7E).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Color(0xFFFF5E7E)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COUPLE ROOM CODE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          pairCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                    tooltip: 'Copy Code',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: pairCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied code $pairCode! Share with your partner ❤️'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.white70, size: 20),
                    tooltip: 'Change Code',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const PairingScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            if (!_supabase.isConfigured)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.cloud_off, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Live sync not connected yet. Tap here to add your free Supabase URL & Key.',
                          style: TextStyle(color: Colors.amber, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Alarms Stream List
            Expanded(
              child: StreamBuilder<List<AlarmModel>>(
                stream: _supabase.getAlarmsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF5E7E)),
                    );
                  }

                  final alarms = snapshot.data ?? [];
                  _alarmService.updateAlarms(alarms);

                  if (alarms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm_add_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No alarms set yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the + button below to add an alarm\nfor you and your partner!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white38),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      return _buildAlarmCard(alarm);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
          );
        },
        backgroundColor: const Color(0xFFFF5E7E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Alarm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAlarmCard(AlarmModel alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: alarm.isEnabled
              ? const Color(0xFFFF5E7E).withOpacity(0.4)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.formattedTime,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: alarm.isEnabled ? Colors.white : Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 14,
                      color: alarm.isEnabled ? const Color(0xFFFF5E7E) : Colors.white24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      alarm.repeatDaysSummary,
                      style: TextStyle(
                        fontSize: 13,
                        color: alarm.isEnabled ? Colors.white70 : Colors.white24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (alarm.requireBothToDismiss) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5E7E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFF5E7E).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.group, size: 12, color: Color(0xFFFF5E7E)),
                            SizedBox(width: 4),
                            Text(
                              'Dual Off',
                              style: TextStyle(color: Color(0xFFFF5E7E), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        '${alarm.title} • by ${alarm.createdByName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: alarm.isEnabled ? const Color(0xFFFF9966) : Colors.white24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: alarm.isEnabled,
            activeColor: const Color(0xFFFF5E7E),
            onChanged: (val) {
              _supabase.toggleAlarm(alarm.id, val);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38),
            onPressed: () {
              _supabase.deleteAlarm(alarm.id);
            },
          ),
        ],
      ),
    );
  }
}
