import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/room.dart';
import '../Models/building.dart';
import '../Models/Enums/room_status.dart';
import '../Models/Enums/equipment_type.dart';
import '../Models/room_equipment.dart';
import '../Services/building_service.dart';
import '../Services/admin_repository.dart';

class AdminRoomDetailScreen extends ConsumerStatefulWidget {
  final Room? room; // null implies creating a new room

  const AdminRoomDetailScreen({super.key, this.room});

  @override
  ConsumerState<AdminRoomDetailScreen> createState() => _AdminRoomDetailScreenState();
}

class _AdminRoomDetailScreenState extends ConsumerState<AdminRoomDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;
  
  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  late TextEditingController _confirmationCodeController;
  
  // State
  List<Building> _buildings = [];
  bool _isLoadingBuildings = true;
  int? _selectedBuildingId;
  List<RoomEquipment> _equipmentList = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.room == null; // Edit mode by default if creating
    
    _nameController = TextEditingController(text: widget.room?.name ?? "");
    _numberController = TextEditingController(text: widget.room?.roomNumber ?? "");
    _capacityController = TextEditingController(text: widget.room?.capacity.toString() ?? "");
    _descriptionController = TextEditingController(text: widget.room?.description ?? "");
    _confirmationCodeController = TextEditingController(text: widget.room?.confirmationCode ?? "");
    
    // Initial building logic
    if (widget.room != null) {
      _selectedBuildingId = widget.room?.building?.id ?? (int.tryParse(widget.room!.location) ?? 1); 
      // Fallback logic for location string might be needed if building obj missing
    }
    
    _equipmentList = widget.room != null ? List.from(widget.room!.equipment) : [];
    
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    try {
      final buildings = await BuildingService().getBuildings();
      if (mounted) {
        setState(() {
          _buildings = buildings;
          _isLoadingBuildings = false;
          // Set default if creating and none selected
          if (_selectedBuildingId == null && _buildings.isNotEmpty) {
            _selectedBuildingId = _buildings.first.id;
          } else if (_selectedBuildingId != null) {
             // Ensure selected ID exists in list, or fallback
             if (!_buildings.any((b) => b.id == _selectedBuildingId)) {
               if (_buildings.isNotEmpty) _selectedBuildingId = _buildings.first.id;
             }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBuildings = false);
    }
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBuildingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a building"), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final buildingName = _buildings
          .firstWhere((b) => b.id == _selectedBuildingId, orElse: () => Building(id: -1, name: "Unknown"))
          .name;

      final roomData = Room(
        id: widget.room?.id ?? "",
        name: _nameController.text,
        roomNumber: _numberController.text,
        capacity: int.parse(_capacityController.text),
        floor: widget.room?.floor ?? 0,
        location: buildingName,
        equipment: _equipmentList,
        currentStatus: widget.room?.currentStatus ?? RoomStatus.free,
        estimatedWalkingTime: widget.room?.estimatedWalkingTime ?? Duration.zero,
        building: Building(id: _selectedBuildingId!, name: buildingName),
        description: _descriptionController.text,
        confirmationCode: _confirmationCodeController.text,
      );

      bool success;
      if (widget.room == null) {
        success = await ref.read(adminRepositoryProvider).createRoom(roomData, _selectedBuildingId!);
      } else {
        success = await ref.read(adminRepositoryProvider).updateRoom(roomData.id, roomData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved successfully!")));
        Navigator.pop(context, true); // Return true to trigger reload
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Error saving room"), backgroundColor: Theme.of(context).colorScheme.error));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Theme.of(context).colorScheme.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  
  Future<void> _deleteRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Room?"),
        content: Text("Do you really want to delete '${widget.room?.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed && widget.room != null) {
      setState(() => _isSaving = true);
      final success = await ref.read(adminRepositoryProvider).deleteRoom(widget.room!.id);
      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Error deleting room"), backgroundColor: Theme.of(context).colorScheme.error));
           setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCreating = widget.room == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreating ? "New Room" : (_isEditing ? "Edit Room" : "Room Details")),
        actions: [
          if (!isCreating && !_isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.error),
              onPressed: _deleteRoom,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isEditing ? _saveRoom : () => setState(() => _isEditing = true),
        icon: _isSaving 
          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2)) 
          : Icon(_isEditing ? Icons.save : Icons.edit),
        label: Text(_isEditing ? "Save" : "Edit"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoadingBuildings 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing ? _buildEditForm(colorScheme) : _buildDetailView(colorScheme),
            ),
    );
  }

  Widget _buildDetailView(ColorScheme colorScheme) {
    final room = widget.room!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.roomNumber,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
              ),
              Text(
                room.name,
                style: TextStyle(fontSize: 20, color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Info Grid
        _buildInfoRow(Icons.business, "Building", room.location, colorScheme),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.people, "Capacity", "${room.capacity} People", colorScheme),
        const SizedBox(height: 16),
        if (room.description.isNotEmpty) ...[
          _buildInfoRow(Icons.description, "Description", room.description, colorScheme),
          const SizedBox(height: 16),
        ],
        _buildInfoRow(Icons.key, "Conf. Code", room.confirmationCode ?? "N/A", colorScheme), // Assuming confirmationCode exists or handled
        
        const SizedBox(height: 32),
        Text("Equipment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
        const SizedBox(height: 12),
        if (room.equipment.isEmpty)
          Text("No equipment listed.", style: TextStyle(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
        ...room.equipment.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          child: ListTile(
            leading: Icon(_getIconForType(e.type), color: colorScheme.primary),
            title: Text(e.type.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: (e.description != null && e.description!.isNotEmpty) ? Text(e.description!) : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12)),
              child: Text("x${e.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        )),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildEditForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Basic Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(labelText: "Room Number", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Room Name", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedBuildingId,
                  decoration: const InputDecoration(labelText: "Building", border: OutlineInputBorder()),
                  items: _buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: (val) => setState(() => _selectedBuildingId = val),
                  validator: (v) => v == null ? "Required" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: "Capacity", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Description (Optional)", border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
           TextFormField(
            controller: _confirmationCodeController,
            decoration: const InputDecoration(labelText: "Confirmation Code", border: OutlineInputBorder()),
          ),
          
          const SizedBox(height: 32),
          Text("Equipment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 12),
          _EquipmentEditorWidget(
            initialEquipment: _equipmentList, 
            onChanged: (eq) => _equipmentList = eq,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
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
}

// Inline Equipment Editor Widget for the Detail Screen
class _EquipmentEditorWidget extends StatefulWidget {
  final List<RoomEquipment> initialEquipment;
  final Function(List<RoomEquipment>) onChanged;

  const _EquipmentEditorWidget({required this.initialEquipment, required this.onChanged});

  @override
  State<_EquipmentEditorWidget> createState() => _EquipmentEditorWidgetState();
}

class _EquipmentEditorWidgetState extends State<_EquipmentEditorWidget> {
  late List<RoomEquipment> _list;

  @override
  void initState() {
    super.initState();
    _list = widget.initialEquipment;
  }

  void _notify() => widget.onChanged(_list);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        if (_list.isEmpty)
           Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No equipment added", style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
        ..._list.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<EquipmentType>(
                          value: item.type,
                          decoration: const InputDecoration(labelText: "Type", isDense: true, border: OutlineInputBorder()),
                          items: EquipmentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _list[index] = item.copyWith(type: val);
                                _notify();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: item.quantity.toString(),
                          decoration: const InputDecoration(labelText: "Qty", isDense: true, border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setState(() {
                              _list[index] = item.copyWith(quantity: int.tryParse(val) ?? 1);
                              _notify();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colorScheme.error),
                        onPressed: () {
                          setState(() {
                            _list.removeAt(index);
                            _notify();
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: item.description,
                    decoration: const InputDecoration(labelText: "Description / Details", isDense: true, border: OutlineInputBorder()),
                    onChanged: (val) {
                       _list[index] = item.copyWith(description: val);
                       _notify();
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _list.add(RoomEquipment(id: "", type: EquipmentType.other, quantity: 1, description: ""));
              _notify();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Equipment Item"),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
        ),
      ],
    );
  }
}
