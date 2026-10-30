import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import '../services/supabase_service.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({Key? key}) : super(key: key);

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final TextEditingController _titleController = TextEditingController(text: 'Wake up together ❤️');
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Default weekdays
  bool _requireBothToDismiss = true;
  bool _isLoading = false;

  final List<String> _quickTags = [
    'Wake up together ❤️',
    'Good morning babe ☀️',
    'College / Work 🎒',
    'Gym / Workout 💪',
    'Night call 🌙',
  ];

  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF5E7E),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1B2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAlarm() async {
    final pairCode = SupabaseService().pairCode;
    if (pairCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please link your couple room first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newAlarm = AlarmModel(
      id: const Uuid().v4(),
      pairCode: pairCode,
      title: _titleController.text.trim().isEmpty ? 'Wake up ❤️' : _titleController.text.trim(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      isEnabled: true,
      repeatDays: _selectedDays.toList()..sort(),
      requireBothToDismiss: _requireBothToDismiss,
      dismissedBy: const [],
      createdByName: SupabaseService().userName ?? 'Me',
      createdAt: DateTime.now(),
    );

    await SupabaseService().addAlarm(newAlarm);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    final timeFormatted = DateFormat('hh:mm a').format(dt);

    return Scaffold(
      backgroundColor: const Color(0xFF13111C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Shared Alarm', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big Time Display Tappable
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B2E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFF5E7E).withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeFormatted,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.touch_app, size: 16, color: Color(0xFFFF5E7E)),
                          SizedBox(width: 6),
                          Text(
                            'Tap to change time',
                            style: TextStyle(color: Color(0xFFFF5E7E), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Dual Confirmation Switch Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B2E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFF5E7E).withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5E7E).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_rounded, color: Color(0xFFFF5E7E), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Both Must Turn Off',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Alarm keeps ringing until both of you tap Turn Off ❤️',
                            style: TextStyle(fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _requireBothToDismiss,
                      activeColor: const Color(0xFFFF5E7E),
                      onChanged: (val) {
                        setState(() => _requireBothToDismiss = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Repeat Days Selector
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Repeat on Days',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1; // 1 to 7
                  final isSelected = _selectedDays.contains(dayNumber);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(dayNumber);
                        } else {
                          _selectedDays.add(dayNumber);
                        }
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFF1E1B2E),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF5E7E) : Colors.white12,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _dayLabels[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Title input
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Message / Note for Her',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Good morning my love ❤️',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E1B2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickTags.map((tag) {
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    backgroundColor: const Color(0xFF1E1B2E),
                    onPressed: () {
                      setState(() => _titleController.text = tag);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveAlarm,
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Set & Sync to Both Phones',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5E7E),
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
      ),
    );
  }
}
