import 'package:flutter/material.dart';
import '../common/FormLabel.dart';
import '../common/TimeDropdown.dart';
import '../common/DurationChip.dart';
import '../common/EquipmentCheckbox.dart';
import '../../Screens/BookingAvailabilityPage.dart';

class BookingDetailsCard extends StatefulWidget {
  @override
  State<BookingDetailsCard> createState() => _BookingDetailsCardState();
}

class _BookingDetailsCardState extends State<BookingDetailsCard> {
  String _selectedBuilding = 'Main Campus';
  String _selectedStartTime = '09:00';
  String _selectedEndTime = '10:00';
  int _attendees = 4;
  DateTime _selectedDate = DateTime(2026, 1, 9);

  late final TextEditingController _attendeesController;

  Map<String, bool> _equipment = {
    'Computer': false,
    'Display': false,
    'Whiteboard': false,
    'Phone': false,
    'Video': false,
    'WiFi': false,
  };

  @override
  void initState() {
    super.initState();
    _attendeesController = TextEditingController(text: _attendees.toString());
  }

  @override
  void dispose() {
    _attendeesController.dispose();
    super.dispose();
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
              // Header
              Row(
                children: [
                  Icon(Icons.search, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Building/Office Dropdown
              FormLabel('Building / Office', primaryColor),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBuilding,
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
                items: ['Main Campus', 'Building A', 'Building B', 'Building C']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBuilding = value ?? 'Main Campus';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Meeting Date
              FormLabel('Meeting Date', primaryColor),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF333535) : Colors.white,
                    border: Border.all(color: mutedColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Number of Attendees
              FormLabel('Number of Attendees', primaryColor),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _attendeesController,
                      keyboardType: TextInputType.number,
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
                      style: TextStyle(color: textColor),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: Colors.white,
                          onPressed: _attendees > 1
                              ? () {
                            setState(() {
                              _attendees--;
                              _attendeesController.text = _attendees.toString();
                            });
                          }
                              : null,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _attendees++;
                              _attendeesController.text = _attendees.toString();
                            });
                          },
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Section - Start and End Time
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FormLabel('Start Time', primaryColor),
                        const SizedBox(height: 8),
                        TimeDropdown(
                          selectedTime: _selectedStartTime,
                          onChanged: (value) {
                            setState(() {
                              _selectedStartTime = value;
                            });
                          },
                          isDark: isDark,
                          primaryColor: primaryColor,
                          mutedColor: mutedColor,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FormLabel('End Time', primaryColor),
                        const SizedBox(height: 8),
                        TimeDropdown(
                          selectedTime: _selectedEndTime,
                          onChanged: (value) {
                            setState(() {
                              _selectedEndTime = value;
                            });
                          },
                          isDark: isDark,
                          primaryColor: primaryColor,
                          mutedColor: mutedColor,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Duration Buttons
              Text(
                'Quick Duration',
                style: TextStyle(
                  fontSize: 12,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['30 min', '1 hour', '1.5 hours', '2 hours']
                    .map((duration) => DurationChip(duration, primaryColor))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Meeting Duration Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meeting Duration',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '1h 0min',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time Slot',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedColor,
                      ),
                    ),
                    Text(
                      '09:00 - 10:00',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Required Equipment Section
              Text(
                'Required Equipment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,  // ← Key: lets grid size itself
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _equipment.entries.map((entry) {
                  return EquipmentCheckbox(
                    label: entry.key,
                    isSelected: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _equipment[entry.key] = value ?? false;
                      });
                    },
                    isDark: isDark,
                    primaryColor: primaryColor,
                    textColor: textColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Find Available Rooms Button
              // Find Available Rooms Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Collect selected equipment
                    List<String> selectedEquipment = _equipment.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingAvailabilityPage(

                          date: _selectedDate,

                          isFromQuickCalendar: false,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Find Available Rooms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
