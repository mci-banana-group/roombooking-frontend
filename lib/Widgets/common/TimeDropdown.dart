import 'package:flutter/material.dart';

class TimeDropdown extends StatelessWidget {
  final String selectedTime;
  final Function(String) onChanged;
  final bool isDark;
  final Color primaryColor;
  final Color mutedColor;
  final Color textColor;
  final String? minTime; // 👈 NEW

  const TimeDropdown({
    required this.selectedTime,
    required this.onChanged,
    required this.isDark,
    required this.primaryColor,
    required this.mutedColor,
    required this.textColor,
    this.minTime,
  });

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    final allTimes = <String>[];

    // 06:00 → 23:30
    for (int h = 6; h < 24; h++) {
      for (int m in [0, 30]) {
        allTimes.add(
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
        );
      }
    }

    // Add 24:00 manually
    allTimes.add('24:00');

    // ⛔ Filter invalid end times
    final times = minTime == null
        ? allTimes
        : allTimes
        .where((t) => _toMinutes(t) > _toMinutes(minTime!))
        .toList();

    return DropdownButtonFormField<String>(
      value: times.contains(selectedTime) ? selectedTime : times.first,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF333535) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: mutedColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: mutedColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: times
          .map(
            (time) => DropdownMenuItem(
          value: time,
          child: Text(time),
        ),
      )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
