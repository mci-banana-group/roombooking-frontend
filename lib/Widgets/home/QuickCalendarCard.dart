import 'package:flutter/material.dart';

import '../../Screens/BookingAvailabilityPage.dart';

class QuickCalendarCard extends StatefulWidget {
  @override
  State createState() => _QuickCalendarCardState();
}

class _QuickCalendarCardState extends State<QuickCalendarCard> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize with today's date
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
    _currentMonth = DateTime(today.year, today.month);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Card(
      elevation: 2,
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth =
                            DateTime(_currentMonth.year, _currentMonth.month - 1);
                      });
                    },
                    icon: Icon(Icons.chevron_left, color: primaryColor),
                    padding: EdgeInsets.zero,
                    constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  Text(
                    _getMonthYear(_currentMonth),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth =
                            DateTime(_currentMonth.year, _currentMonth.month + 1);
                      });
                    },
                    icon: Icon(Icons.chevron_right, color: primaryColor),
                    padding: EdgeInsets.zero,
                    constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                    .map((day) => Flexible(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: mutedColor,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              _buildCalendarGrid(_currentMonth, primaryColor, textColor,
                  mutedColor, isDark),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Click on any date to view its available rooms on the day',
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month, Color primaryColor,
      Color textColor, Color mutedColor, bool isDark) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;
    final today = DateTime.now();
    final days = [];

    for (int i = 0; i < firstWeekday; i++) {
      days.add(0);
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: days.map((day) {
        if (day == 0) {
          return const SizedBox.shrink();
        }

        final currentDate = DateTime(month.year, month.month, day);
        final isSelected = day == _selectedDate.day &&
            _selectedDate.month == month.month &&
            _selectedDate.year == month.year;

        // Check if date is in the past (before today)
        final isPast = currentDate.isBefore(
          DateTime(today.year, today.month, today.day),
        );

        return GestureDetector(
          onTap: isPast
              ? null
              : () {
            final selectedDate = DateTime(month.year, month.month, day);
            setState(() {
              _selectedDate = selectedDate;
            });

            // Navigate to BookingAvailabilityPage with only the date
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingAvailabilityPage(
                  date: selectedDate,
                  isFromQuickCalendar: true,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : isPast
                    ? mutedColor.withOpacity(0.1)
                    : mutedColor.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isPast
                      ? mutedColor.withOpacity(0.4)
                      : textColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}