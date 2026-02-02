import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/room.dart';
import '../Models/Enums/room_status.dart';
import '../Models/building.dart';
import '../Services/admin_repository.dart';
import '../Services/building_service.dart';
import '../Models/room_equipment.dart';
import '../Models/Enums/equipment_type.dart';
import 'AdminRoomDetailScreen.dart';


class AdminRoomManagement extends ConsumerStatefulWidget {
  const AdminRoomManagement({super.key});

  @override
  ConsumerState<AdminRoomManagement> createState() => _AdminRoomManagementState();
}

class _AdminRoomManagementState extends ConsumerState<AdminRoomManagement> {
  List<Room> rooms = [];
  bool _isLoading = true;
  // null = ignore, true = must have, false = must not have
  final Map<EquipmentType, bool?> _filterState = {
    for (var type in EquipmentType.values) type: null,
  };

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _cycleFilter(EquipmentType type) {
    setState(() {
      final current = _filterState[type];
      if (current == null) {
        _filterState[type] = true; // Must have
      } else if (current == true) {
        _filterState[type] = false; // Must NOT have
      } else {
        _filterState[type] = null; // Ignore
      }
    });
  }

  bool _roomMatchesFilter(Room room) {
    for (var entry in _filterState.entries) {
      final type = entry.key;
      final requirement = entry.value;
      if (requirement == null) continue;

      final hasEquipment = room.equipment.any((e) => e.type == type && e.quantity > 0);

      if (requirement == true && !hasEquipment) return false;
      if (requirement == false && hasEquipment) return false;
    }
    return true;
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    final fetchedRooms = await ref.read(adminRepositoryProvider).getAllRooms();
    if (mounted) {
      setState(() {
        rooms = fetchedRooms;
        _isLoading = false;
      });
    }
  }

  void _openCreateRoom() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AdminRoomDetailScreen()),
    );
    if (result == true) {
      _loadRooms();
    }
  }

  void _openRoomDetails(Room room) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AdminRoomDetailScreen(room: room)),
    );
    if (result == true) {
      _loadRooms();
    }
  }

  void _confirmDelete(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Room?"),
          content: Text("Are you sure you want to delete ${room.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
       final success = await ref.read(adminRepositoryProvider).deleteRoom(room.id);
       if (success) {
         _loadRooms();
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room deleted!")));
       } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Error deleting room"), backgroundColor: Theme.of(context).colorScheme.error));
       }
    }
  }

  IconData _getIconForType(EquipmentType type) {
    switch (type) {
      case EquipmentType.beamer: return Icons.videocam;
      case EquipmentType.whiteboard: return Icons.edit;
      case EquipmentType.display: return Icons.tv;
      case EquipmentType.videoConference: return Icons.video_call;
      case EquipmentType.hdmiCable: return Icons.cable;
      case EquipmentType.other: return Icons.devices;
    }
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Filter Equipment"),
              content: SizedBox(
                width: 400,
                child: ListView(
                  shrinkWrap: true,
                  children: EquipmentType.values.map((type) {
                    final state = _filterState[type];
                    IconData icon;
                    Color color;
                    String statusText;

                    if (state == true) {
                      icon = Icons.check_circle;
                      color = colorScheme.primary;
                      statusText = "Must Have";
                    } else if (state == false) {
                      icon = Icons.cancel;
                      color = colorScheme.error;
                      statusText = "Must Not Have";
                    } else {
                      icon = Icons.circle_outlined;
                      color = colorScheme.outline;
                      statusText = "Ignore";
                    }

                    return ListTile(
                      leading: Icon(
                        _getIconForType(type),
                        color: colorScheme.secondary,
                      ),
                      title: Text(type.displayName),
                      subtitle: Text(statusText, style: TextStyle(color: color, fontSize: 12)),
                      trailing: IconButton(
                        icon: Icon(icon, color: color),
                        onPressed: () {
                          _cycleFilter(type);
                          setStateDialog(() {});
                        },
                      ),
                      onTap: () {
                         _cycleFilter(type);
                         setStateDialog(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRooms = rooms.where(_roomMatchesFilter).toList();
    final activeFiltersCount = _filterState.values.where((v) => v != null).length;

    final Map<String, List<Room>> groupedRooms = {};
    for (var room in filteredRooms) {
      String buildingKey = room.location.isNotEmpty ? room.location : "Unknown Building";
      if (!groupedRooms.containsKey(buildingKey)) {
        groupedRooms[buildingKey] = [];
      }
      groupedRooms[buildingKey]!.add(room);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  Text("Room Management", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Filter
                  OutlinedButton.icon(
                    onPressed: _openFilterDialog,
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: Text(activeFiltersCount > 0 ? "Filters ($activeFiltersCount)" : "Filter"),
                  ),
                  const SizedBox(width: 12),
                  // Add Room
                  FilledButton.icon(
                    onPressed: _openCreateRoom,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Room"),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRooms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.meeting_room_outlined, size: 48, color: colorScheme.outline.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text("No rooms found", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                          itemCount: groupedRooms.keys.length,
                          itemBuilder: (context, index) {
                            String buildingName = groupedRooms.keys.elementAt(index);
                            List<Room> buildingRooms = groupedRooms[buildingName]!;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              color: colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              clipBehavior: Clip.antiAlias,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  backgroundColor: Colors.transparent,
                                  collapsedBackgroundColor: Colors.transparent,
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Icon(Icons.business_rounded, color: colorScheme.primary),
                                  title: Text(
                                    buildingName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "${buildingRooms.length} Rooms",
                                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                                  ),
                                  children: buildingRooms.map((room) => _buildRoomItem(room)).toList(),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomItem(Room room) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.2)),
        ListTile(
          onTap: () => _openRoomDetails(room),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text("Room: ${room.name}", style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Text("${room.capacity}", style: TextStyle(color: colorScheme.secondary)),
                const SizedBox(width: 16),
                if (room.equipment.isNotEmpty)
                  ...room.equipment.take(5).map((e) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(_getIconForType(e.type), size: 16, color: colorScheme.onSurfaceVariant),
                  )),
              ],
            ),
          ),
          trailing: Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: room.currentStatus.name == 'free' ? colorScheme.primaryContainer : colorScheme.tertiaryContainer,
               borderRadius: BorderRadius.circular(12)
             ),
             child: Text(
               room.currentStatus.name.toUpperCase(),
               style: TextStyle(
                 fontSize: 10, 
                 fontWeight: FontWeight.bold,
                 color: room.currentStatus.name == 'free' ? colorScheme.onPrimaryContainer : colorScheme.onTertiaryContainer,
               ),
             ),
           ),
        ),
      ],
    );
  }
}
