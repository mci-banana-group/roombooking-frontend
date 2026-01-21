import 'package:flutter/material.dart';

class TimeDropdown extends StatelessWidget {
  final String selectedTime;
  final Function(String) onChanged;
  final bool isDark;
  final Color primaryColor;
  final Color mutedColor;
  final Color textColor;

  const TimeDropdown({
    required this.selectedTime,
    required this.onChanged,
    required this.isDark,
    required this.primaryColor,
    required this.mutedColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final times = <String>[];
    for (int i = 0; i < 24; i++) {
      times.add('${i.toString().padLeft(2, '0')}:00');
      times.add('${i.toString().padLeft(2, '0')}:30');
    }

    return DropdownButtonFormField<String>(
      value: selectedTime,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Color(0xFF333535) : Colors.white,
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
      items: times.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
