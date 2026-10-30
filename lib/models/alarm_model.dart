import 'package:intl/intl.dart';

class AlarmModel {
  final String id;
  final String pairCode;
  final String title;
  final int hour;
  final int minute;
  final bool isEnabled;
  final List<int> repeatDays; // 1 = Mon, ..., 7 = Sun
  final bool requireBothToDismiss;
  final List<String> dismissedBy;
  final String createdByName;
  final DateTime createdAt;

  AlarmModel({
    required this.id,
    required this.pairCode,
    required this.title,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.repeatDays = const [],
    this.requireBothToDismiss = true,
    this.dismissedBy = const [],
    this.createdByName = 'Partner',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedTime {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat('hh:mm a').format(dt);
  }

  String get repeatDaysSummary {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Everyday';
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5)) {
      return 'Weekdays';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((d) => days[d - 1]).join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pair_code': pairCode,
      'title': title,
      'hour': hour,
      'minute': minute,
      'is_enabled': isEnabled,
      'repeat_days': repeatDays,
      'require_both_to_dismiss': requireBothToDismiss,
      'dismissed_by': dismissedBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      pairCode: json['pair_code'] as String,
      title: json['title'] as String? ?? 'Wake Up ❤️',
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      isEnabled: json['is_enabled'] as bool? ?? true,
      repeatDays: (json['repeat_days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      requireBothToDismiss: json['require_both_to_dismiss'] as bool? ?? true,
      dismissedBy: (json['dismissed_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdByName: json['created_by_name'] as String? ?? 'Partner',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  AlarmModel copyWith({
    String? id,
    String? pairCode,
    String? title,
    int? hour,
    int? minute,
    bool? isEnabled,
    List<int>? repeatDays,
    bool? requireBothToDismiss,
    List<String>? dismissedBy,
    String? createdByName,
    DateTime? createdAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      pairCode: pairCode ?? this.pairCode,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      requireBothToDismiss: requireBothToDismiss ?? this.requireBothToDismiss,
      dismissedBy: dismissedBy ?? this.dismissedBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
