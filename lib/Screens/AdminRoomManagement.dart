import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/room.dart';
import '../Models/Enums/room_status.dart';
import '../Models/building.dart';
import '../Services/admin_repository.dart';
import '../Services/building_service.dart';


class AdminRoomManagement extends ConsumerStatefulWidget {
  const AdminRoomManagement({super.key});

  @override
  ConsumerState<AdminRoomManagement> createState() => _AdminRoomManagementState();
}

class _AdminRoomManagementState extends ConsumerState<AdminRoomManagement> {
  List<Room> rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final loadedRooms = await ref.read(adminRepositoryProvider).getAllRooms();
      if (mounted) {
        setState(() {
          rooms = loadedRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Fehler beim Laden: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //Dialoge zum Erstellen, Bearbeiten, Löschen
  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateRoomDialog(
        onSave: (newRoom, buildingId) async {
          final success = await ref.read(adminRepositoryProvider).createRoom(newRoom, buildingId);
          if (success) {
            await _loadRooms();
            if (mounted) Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room created!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error creating room"), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  void _openEditDialog(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => _EditRoomDialog(
        room: room,
        onSave: (updatedRoom) async {
          final success = await ref.read(adminRepositoryProvider).updateRoom(room.id, updatedRoom);
          if (success) {
            await _loadRooms();
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room updated!")));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error updating room"), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  void _confirmDelete(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Room?"),
        content: Text("Do you really want to delete '${room.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(adminRepositoryProvider).deleteRoom(room.id);
              if (success) {
                await _loadRooms();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room deleted!")));
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error deleting room"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gruppierung nach Gebäude
    final Map<String, List<Room>> groupedRooms = {};
    for (var room in rooms) {
      String buildingKey = room.location.isNotEmpty ? room.location : "Unknown Building";
      if (!groupedRooms.containsKey(buildingKey)) {
        groupedRooms[buildingKey] = [];
      }
      groupedRooms[buildingKey]!.add(room);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? Center(child: Text("No rooms available.", style: TextStyle(color: Colors.grey[400])))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedRooms.keys.length,
                  itemBuilder: (context, index) {
                    String buildingName = groupedRooms.keys.elementAt(index);
                    List<Room> buildingRooms = groupedRooms[buildingName]!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.business, color: Colors.teal),
                        ),
                        title: Text(
                          buildingName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text("${buildingRooms.length} Rooms", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.teal.withOpacity(0.1),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                        childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                        children: buildingRooms.map((room) => _buildRoomItem(room)).toList(),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildRoomItem(Room room) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Text(
            room.roomNumber,
            style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Capacity: ${room.capacity}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               margin: const EdgeInsets.only(right: 8),
               decoration: BoxDecoration(
                 color: room.currentStatus.name == 'free' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(4)
               ),
               child: Text(
                 room.currentStatus.name.toUpperCase(),
                 style: TextStyle(
                   fontSize: 10, 
                   fontWeight: FontWeight.bold,
                   color: room.currentStatus.name == 'free' ? Colors.green : Colors.orange,
                 ),
               ),
             ),
             IconButton(
               icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
               onPressed: () => _openEditDialog(room),
               padding: EdgeInsets.zero,
               constraints: const BoxConstraints(),
             ),
             const SizedBox(width: 12),
             IconButton(
               icon: const Icon(Icons.delete, size: 20, color: Colors.red),
               onPressed: () => _confirmDelete(room),
               padding: EdgeInsets.zero,
               constraints: const BoxConstraints(),
             ),
          ],
        ),
      ),
    );
  }
}

//Helper-Widgets für die Dialoge
class _CreateRoomDialog extends StatefulWidget {
  final Function(Room, int) onSave; 
  const _CreateRoomDialog({required this.onSave});
  @override
  State<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _confirmationCodeController = TextEditingController();
  
  List<Building> _buildings = [];
  bool _isLoadingBuildings = true;
  int? _selectedBuildingId;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    try {
      final buildings = await BuildingService().getBuildings();
      if (mounted) {
        setState(() {
          _buildings = buildings;
          _isLoadingBuildings = false;
          if (_buildings.isNotEmpty) {
            _selectedBuildingId = _buildings.first.id;
          }
        });
      }
    } catch (e) {
      print("Error loading buildings: $e");
      if (mounted) setState(() => _isLoadingBuildings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create new room"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Room Name (e.g. Meeting A)"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: "Room Number (e.g. 101)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required field";
                  if (int.tryParse(value) == null) return "Please enter only numbers!";
                  return null;
                },
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),
              TextFormField(
                controller: _confirmationCodeController,
                decoration: const InputDecoration(labelText: "Confirmation Code (4 digits)"),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required field";
                  if (v.length != 4) return "Must be 4 digits";
                  if (int.tryParse(v) == null) return "Only numbers allowed";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isLoadingBuildings
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedBuildingId,
                      decoration: const InputDecoration(labelText: "Building"),
                      items: _buildings.map((building) {
                        return DropdownMenuItem<int>(
                          value: building.id,
                          child: Text(building.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBuildingId = value;
                        });
                      },
                      validator: (value) => value == null ? "Please select a building" : null,
                    ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Find the building name for location string
              final buildingName = _buildings
                  .firstWhere((b) => b.id == _selectedBuildingId, orElse: () => Building(id: -1, name: "Unknown"))
                  .name;
                  
              final newRoom = Room(
                id: "", 
                name: _nameController.text,
                roomNumber: _numberController.text,
                capacity: int.parse(_capacityController.text),
                floor: 0, 
                location: buildingName,
                equipment: [], 
                currentStatus: RoomStatus.free, 
                estimatedWalkingTime: Duration.zero,
                confirmationCode: _confirmationCodeController.text,
              );
              widget.onSave(newRoom, _selectedBuildingId!);
            }
          },
          child: const Text("Create"),
        )
      ],
    );
  }
}

class _EditRoomDialog extends StatefulWidget {
  final Room room;
  final Function(Room) onSave;
  const _EditRoomDialog({required this.room, required this.onSave});
  @override
  State<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<_EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _capacityController;
  late TextEditingController _buildingIdController;
  late TextEditingController _descriptionController;
  late TextEditingController _confirmationCodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _numberController = TextEditingController(text: widget.room.roomNumber);
    _capacityController = TextEditingController(text: widget.room.capacity.toString());
    _buildingIdController = TextEditingController(text: widget.room.building?.id.toString() ?? "1");
    _descriptionController = TextEditingController(text: widget.room.description);
    _confirmationCodeController = TextEditingController(text: widget.room.confirmationCode);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Room: ${widget.room.name}"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Room Name"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: "Room Number"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: _confirmationCodeController,
                decoration: const InputDecoration(labelText: "Confirmation Code"),
                maxLength: 4,
              ),
              TextFormField(
                controller: _buildingIdController,
                decoration: const InputDecoration(labelText: "Building ID"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedRoom = Room(
                id: widget.room.id, 
                name: _nameController.text,
                roomNumber: _numberController.text,
                capacity: int.parse(_capacityController.text),
                floor: widget.room.floor,
                location: widget.room.location,
                equipment: widget.room.equipment, 
                currentStatus: widget.room.currentStatus,
                estimatedWalkingTime: widget.room.estimatedWalkingTime,
                building: Building(
                  id: int.tryParse(_buildingIdController.text) ?? 1,
                  name: "Building ${int.tryParse(_buildingIdController.text)}",
                ),
                description: _descriptionController.text,
                confirmationCode: _confirmationCodeController.text,
              );
              widget.onSave(updatedRoom);
            }
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}