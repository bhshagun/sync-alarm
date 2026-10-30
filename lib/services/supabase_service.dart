import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import '../models/alarm_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String defaultUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String defaultAnonKey = 'YOUR_ANON_KEY';

  SupabaseClient? _client;
  bool isConfigured = false;
  String? pairCode;
  String? userName;

  SupabaseClient get client => _client!;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    pairCode = prefs.getString('pair_code');
    userName = prefs.getString('user_name') ?? 'Me';

    final savedUrl = prefs.getString('supabase_url') ?? defaultUrl;
    final savedKey = prefs.getString('supabase_anon_key') ?? defaultAnonKey;

    if (savedUrl != defaultUrl && savedKey != defaultAnonKey) {
      try {
        _client = SupabaseClient(savedUrl, savedKey);
        isConfigured = true;
      } catch (e) {
        debugPrint('Supabase init error: $e');
      }
    }
  }

  Future<void> configureCredentials(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supabase_url', url);
    await prefs.setString('supabase_anon_key', anonKey);

    _client = SupabaseClient(url, anonKey);
    isConfigured = true;
  }

  Future<void> savePairing({required String code, required String name}) async {
    pairCode = code.trim().toUpperCase();
    userName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pair_code', pairCode!);
    await prefs.setString('user_name', userName!);
  }

  Future<void> clearPairing() async {
    pairCode = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pair_code');
  }

  Stream<List<AlarmModel>> getAlarmsStream() {
    if (!isConfigured || pairCode == null || _client == null) {
      return Stream.value([]);
    }

    return _client!
        .from('alarms')
        .stream(primaryKey: ['id'])
        .eq('pair_code', pairCode!)
        .order('hour', ascending: true)
        .order('minute', ascending: true)
        .map((records) => records.map((json) => AlarmModel.fromJson(json)).toList());
  }

  Stream<AlarmModel?> streamSingleAlarm(String alarmId) {
    if (!isConfigured || _client == null) {
      return Stream.value(null);
    }

    return _client!
        .from('alarms')
        .stream(primaryKey: ['id'])
        .eq('id', alarmId)
        .map((records) {
          if (records.isEmpty) return null;
          return AlarmModel.fromJson(records.first);
        });
  }

  Future<void> markAlarmDismissed(String alarmId, String name) async {
    if (!isConfigured || _client == null) return;

    try {
      final res = await _client!
          .from('alarms')
          .select('dismissed_by')
          .eq('id', alarmId)
          .single();

      final list = (res['dismissed_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      if (!list.contains(name)) {
        list.add(name);
        await _client!
            .from('alarms')
            .update({'dismissed_by': list})
            .eq('id', alarmId);
      }
    } catch (e) {
      debugPrint('Error marking alarm dismissed: $e');
    }
  }

  Future<void> resetAlarmDismissed(String alarmId) async {
    if (!isConfigured || _client == null) return;
    try {
      await _client!
          .from('alarms')
          .update({'dismissed_by': []})
          .eq('id', alarmId);
    } catch (e) {
      debugPrint('Error resetting alarm: $e');
    }
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('alarms').insert(alarm.toJson());
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    if (!isConfigured || _client == null) return;
    await _client!
        .from('alarms')
        .update(alarm.toJson())
        .eq('id', alarm.id);
  }

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    if (!isConfigured || _client == null) return;
    await _client!
        .from('alarms')
        .update({'is_enabled': isEnabled})
        .eq('id', id);
  }

  Future<void> deleteAlarm(String id) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('alarms').delete().eq('id', id);
  }
}
