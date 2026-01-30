import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/FormLabel.dart';
import '../common/TimeDropdown.dart';
import '../common/DurationChip.dart';
import '../../Screens/BookingAvailabilityPage.dart';
import '../../Services/building_service.dart';
import '../../Services/room_service.dart';
import '../../Models/building.dart';
import '../../Models/Enums/equipment_type.dart';

class BookingDetailsCard extends StatefulWidget {
  final bool isMobile;
  final DateTime selectedDate;
  final Function(int?, String?) onBuildingChanged;

  const BookingDetailsCard({
    super.key,
    this.isMobile = false,
    required this.selectedDate,
    required this.onBuildingChanged,
  });

  @override
  BookingDetailsCardState createState() => BookingDetailsCardState();
}

class BookingDetailsCardState extends State<BookingDetailsCard> {
  final BuildingService _buildingService = BuildingService();
  final RoomService _roomService = RoomService();

  List<Building> _buildings = [];
  int? _selectedBuildingId;
  String? _selectedBuildingName;
  bool _isLoadingBuildings = true;
  String? _buildingsError;

  bool _isLoadingEquipment = false;
  String? _equipmentError;

  String _selectedStartTime = '09:00';
  String _selectedEndTime = '10:00';
  int _attendees = 4;
  String _selectedDuration = '1 hour';

  late final TextEditingController _attendeesController;

  Map<EquipmentType, bool> _equipment = {};
  
  // Collapsible state
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Default to expanded on desktop, collapsed on mobile
    _isExpanded = !widget.isMobile;
    
    _attendeesController = TextEditingController(text: _attendees.toString());
    _initializeTimes();
    _loadBuildings();
  }
  
  @override
  void didUpdateWidget(BookingDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMobile != oldWidget.isMobile) {
      // If switching from desktop to mobile, collapse. 
      // If switching from mobile to desktop, expand.
      setState(() {
        _isExpanded = !widget.isMobile;
      });
    }
  }

  void _initializeTimes() {
    final now = DateTime.now();
    int minutes = now.hour * 60 + now.minute;
    
    // Round to next 30 min
    int remainder = minutes % 30;
    int nextSlot = minutes + (30 - remainder);
    

    int startMinutes = nextSlot % (24 * 60 + 30); 
    if (startMinutes >= 24 * 60) startMinutes = 0; 

    _selectedStartTime = _minutesToTime(startMinutes);
    
    int endMinutes = startMinutes + 60;
    if (endMinutes >= 24 * 60) { 
       endMinutes = endMinutes % (24 * 60);
    }
    
    _selectedEndTime = _minutesToTime(endMinutes);
    _selectedDuration = '1 hour';
  }

  Future<void> _loadBuildings() async {
    try {
      setState(() {
        _isLoadingBuildings = true;
        _buildingsError = null;
      });

      final buildings = await _buildingService.getBuildings();

      if (mounted) {
        setState(() {
          _buildings = buildings;
          _isLoadingBuildings = false;

          if (_buildings.isNotEmpty) {
            _selectedBuildingId = _buildings.first.id;
            _selectedBuildingName = _buildings.first.name;
            widget.onBuildingChanged(_selectedBuildingId, _selectedBuildingName);
            _loadEquipmentForBuilding(_buildings.first.id);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _buildingsError = 'Failed to load buildings: $e';
          _isLoadingBuildings = false;
        });
      }
      print('Error loading buildings: $e');
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _loadEquipmentForBuilding(int buildingId) async {
    try {
      setState(() {
        _isLoadingEquipment = true;
        _equipmentError = null;
        _equipment = {};
      });

      final equipmentList = await _roomService.getRoomEquipment(buildingId);

      if (mounted) {
        setState(() {
          final uniqueEquipmentTypes = <EquipmentType>{};

          for (var item in equipmentList) {
            if (item['name'] != null) {
              final equipmentType = EquipmentType.fromString(item['name'] as String);
              uniqueEquipmentTypes.add(equipmentType);
            }
          }

          _equipment = {};
          for (var equipmentType in uniqueEquipmentTypes) {
            _equipment[equipmentType] = false;
          }

          _equipment = Map.fromEntries(
              _equipment.entries.toList()
                ..sort((a, b) => a.key.displayName.compareTo(b.key.displayName))
          );

          _isLoadingEquipment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _equipmentError = 'Failed to load equipment: $e';
          _isLoadingEquipment = false;
        });
      }
      print('Error loading equipment: $e');
    }
  }

  @override
  void dispose() {
    _attendeesController.dispose();
    super.dispose();
  }

  void findRooms() {
    if (_selectedBuildingId == null) return;

    List<String> selectedEquipment = _equipment.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.apiValue)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingAvailabilityPage(
          date: widget.selectedDate,
          startTime: _selectedStartTime,
          endTime: _selectedEndTime,
          capacity: _attendees,
          equipment: selectedEquipment,
          isFromQuickCalendar: false,
          buildingId: _selectedBuildingId,
          buildingName: _selectedBuildingName,
        ),
      ),
    );
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
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                InkWell(
                  onTap: widget.isMobile 
                      ? () => setState(() => _isExpanded = !_isExpanded) 
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Booking Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                          ),
                        ],
                      ),
                      if (widget.isMobile)
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: mutedColor,
                        ),
                    ],
                  ),
                ),
                
                if (_isExpanded) ...[
                const SizedBox(height: 20),

              // Building Dropdown
              FormLabel('Building / Office', primaryColor),
              const SizedBox(height: 8),
              _isLoadingBuildings
                  ? Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF333535) : Colors.white,
                  border: Border.all(color: mutedColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
                  : _buildingsError != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _buildingsError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadBuildings,
                      icon: Icon(Icons.refresh, size: 18),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
                  : DropdownButtonFormField<int>(
                value: _selectedBuildingId,
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
                items: _buildings
                    .map(
                      (building) => DropdownMenuItem(
                    value: building.id,
                    child: Text(building.name),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    final selected = _buildings.firstWhere((b) => b.id == value);
                    setState(() {
                      _selectedBuildingId = value;
                      _selectedBuildingName = selected.name;
                    });
                    widget.onBuildingChanged(_selectedBuildingId, _selectedBuildingName);
                    _loadEquipmentForBuilding(value);
                  }
                },
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Attendees
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
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(6)),
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

              // Time
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

                              // If a quick duration is selected, maintain it
                              if (_selectedDuration.isNotEmpty) {
                                final startMinutes = _timeToMinutes(_selectedStartTime);
                                final durationMinutes = _parseDuration(_selectedDuration);
                                final newEnd = startMinutes + durationMinutes;

                                // new end time valid?
                                if (newEnd <= 24 * 60) {
                                  _selectedEndTime = _minutesToTime(newEnd);
                                  return;
                                }
                              }

                              // Clear duration and ensure end > start
                              _selectedDuration = '';

                              final startMinutes = _timeToMinutes(_selectedStartTime);
                              final endMinutes = _timeToMinutes(_selectedEndTime);

                              if (endMinutes <= startMinutes) {
                                final newEnd = startMinutes + 30;
                                _selectedEndTime = _minutesToTime(newEnd);
                              }
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
                          minTime: _selectedStartTime, // 👈 magic line
                          onChanged: (value) {
                            setState(() {
                              _selectedEndTime = value;
                              _selectedDuration = '';
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

              // Duration Buttons
              Text(
                'Quick Duration',
                style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['30 min', '1 hour', '1.5 hours', '2 hours'].map((duration) {
                  return DurationChip(
                    duration,
                    primaryColor,
                    isSelected: _selectedDuration == duration,
                    onTap: () {
                      _calculateEndTime(duration);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Duration Info
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
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        Text(
                          _formatDuration(_selectedDuration),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Time Slot', style: TextStyle(fontSize: 12, color: mutedColor)),
                    Text(
                      '$_selectedStartTime - $_selectedEndTime',
                      style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Equipment
              Text(
                'Required Equipment',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 12),
              _isLoadingEquipment
                  ? Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
                  : _equipmentError != null
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_equipmentError!, style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              )
                  : _equipment.isEmpty
                  ? Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No equipment available', style: TextStyle(color: mutedColor, fontSize: 12)),
                ),
              )
                  : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _equipment.entries.map((entry) {
                  return _buildEquipmentCheckbox(entry.key, entry.value, isDark, primaryColor, textColor, mutedColor);
                }).toList(),
              ),
            ],
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildEquipmentCheckbox(
      EquipmentType equipmentType,
      bool isSelected,
      bool isDark,
      Color primaryColor,
      Color textColor,
      Color mutedColor,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _equipment[equipmentType] = !isSelected;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryColor : mutedColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _equipment[equipmentType] = value ?? false;
                  });
                },
                activeColor: primaryColor,
              ),
              Expanded(
                child: Text(
                  equipmentType.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculateEndTime(String duration) {
    final startMinutes = _timeToMinutes(_selectedStartTime);
    final durationMinutes = _parseDuration(duration);

    final endMinutes = startMinutes + durationMinutes;

    // ❌ Do not allow past 24:00
    if (endMinutes > 24 * 60) return;

    setState(() {
      _selectedEndTime = _minutesToTime(endMinutes);
      _selectedDuration = duration;
    });
  }



  int _parseDuration(String duration) {
    if (duration.contains('min')) {
      return int.parse(duration.split(' ')[0]);
    } else if (duration.contains('hour')) {
      final hours = double.parse(duration.split(' ')[0]);
      return (hours * 60).round();
    }
    return 60;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(String duration) {
    if (duration.contains('min')) {
      return '${duration.split(' ')[0]}min';
    } else if (duration.contains('hour')) {
      final hours = double.parse(duration.split(' ')[0]);
      if (hours == 1) {
        return '1h 0min';
      } else if (hours == 1.5) {
        return '1h 30min';
      } else {
        return '${hours.toInt()}h 0min';
      }
    }
    return '1h 0min';
  }
}
