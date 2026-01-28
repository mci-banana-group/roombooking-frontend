import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/room.dart';
import '../Models/Enums/room_status.dart';
import '../Services/admin_repository.dart';
import '../Session.dart'; 
import '../main.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold( // Scaffold hinzugefügt für bessere Struktur
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.view_list), text: 'Bookings'),
              Tab(icon: Icon(Icons.meeting_room), text: 'Rooms'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AdminBookingsOverview(),
            _AdminRoomManagement(), //neue Klasse
          ],
        ),
      ),
    );
  }
}

class _AdminBookingsOverview extends StatelessWidget {
  const _AdminBookingsOverview();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bookings Overview (TODO)'));
  }
}


// Räume

class _AdminRoomManagement extends ConsumerStatefulWidget {
  const _AdminRoomManagement();

  @override
  ConsumerState<_AdminRoomManagement> createState() => _AdminRoomManagementState();
}

class _AdminRoomManagementState extends ConsumerState<_AdminRoomManagement> {
  // Liste der Räume
  List<Room> rooms = [];
  // Variable um prüfen ob geladen wird
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Sofort beim Starten die echten Daten holen
    _loadRooms();
  }

  // Daten vom Server holen
  Future<void> _loadRooms() async {
    try {
      final loadedRooms = await ref.read(adminRepositoryProvider).getAllRooms();
      
      if (mounted) {
        setState(() {
          rooms = loadedRooms;
          _isLoading = false; // Laden fertig
        });
      }
    } catch (e) {
      print("Fehler beim Laden: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Laden fertig (auch bei Fehler, damit der Kreis weggeht)
        });
      }
    }
  }
  //erstellen
  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateRoomDialog(
        onSave: (newRoom, buildingId) async {
          // Lade-Kreis zeigen während des Speicherns (optional, aber schick)
          // setState(() => _isLoading = true); 

          // 1. API Aufruf via Repository
          final success = await ref.read(adminRepositoryProvider).createRoom(newRoom, buildingId);
          
          if (success) {
            // 2. Liste neu vom Server laden, damit wir die echte ID und alles haben
            await _loadRooms(); 
            
            if (mounted) Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Raum erstellt!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fehler beim Erstellen"), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  // bearbeiten
  void _openEditDialog(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => _EditRoomDialog(
        room: room, // Wir übergeben den existierenden Raum
        onSave: (updatedRoom) async {
          // Repository Update aufrufen
          final success = await ref.read(adminRepositoryProvider).updateRoom(room.id, updatedRoom);
          
          if (success) {
            await _loadRooms(); // Liste neu laden
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Raum aktualisiert!")));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fehler beim Update"), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  //löschen
  void _confirmDelete(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Raum löschen?"),
        content: Text("Möchtest du '${room.name}' wirklich löschen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Abbrechen"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Dialog schließen
              
              // Repository Delete aufrufen
              final success = await ref.read(adminRepositoryProvider).deleteRoom(room.id);
              
              if (success) {
                await _loadRooms(); // Liste aktualisieren
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Raum gelöscht!")));
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fehler beim Löschen"), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Löschen", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) // Zeige Ladekreis wenn _isLoading true ist
          : rooms.isEmpty
              ? Center(
                  child: Text("Keine Räume gefunden.\n(Oder Verbindung fehlgeschlagen)", 
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400]))
                )
              : ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: Text(room.roomNumber, style: const TextStyle(color: Colors.teal, fontSize: 12)),
                        ),
                        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Kapazität: ${room.capacity} Personen"),
                        // --- HIER SIND DIE NEUEN BUTTONS ---
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Chip (etwas kleiner gemacht)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(room.currentStatus.name.toUpperCase()),
                                backgroundColor: room.currentStatus.name == 'free' ? Colors.green[100] : Colors.orange[100],
                                labelStyle: const TextStyle(fontSize: 10, color: Colors.black87),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            // Bearbeiten Button
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEditDialog(room),
                              constraints: const BoxConstraints(), // Macht Button kompakter
                              padding: const EdgeInsets.all(8),
                            ),
                            // Löschen Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(room),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// DER DIALOG ZUM ERSTELLEN

class _CreateRoomDialog extends StatefulWidget {
  final Function(Room, int) onSave; // Callback mit Room und BuildingID

  const _CreateRoomDialog({required this.onSave});

  @override
  State<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller für die Textfelder
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _confirmationCodeController = TextEditingController(); // Default empty
  final _buildingIdController = TextEditingController(text: "1"); // Default ID 1

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Neuen Raum erstellen"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Raum Name (z.B. Meeting A)"),
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: "Raum Nummer (z.B. 101)"),
                keyboardType: TextInputType.number,

                validator: (value) {
                  if (value == null || value.isEmpty) return "Pflichtfeld";
                  if (int.tryParse(value) == null) return "Bitte nur Zahlen eingeben!";
                  return null;
                },

              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Kapazität"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
              TextFormField(
                controller: _confirmationCodeController,
                decoration: const InputDecoration(labelText: "Bestätigungscode (4-stellig)"),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Pflichtfeld";
                  if (v.length != 4) return "Muss 4-stellig sein";
                  if (int.tryParse(v) == null) return "Nur Zahlen erlaubt";
                  return null;
                },
              ),
              // Swagger braucht Building ID zwingend!
              TextFormField(
                controller: _buildingIdController,
                decoration: const InputDecoration(labelText: "Building ID (Int)"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Neues Room Objekt erstellen
              // ID ist leer, da sie vom Server kommt
              final newRoom = Room(
                id: "", 
                name: _nameController.text,
                roomNumber: _numberController.text,
                capacity: int.parse(_capacityController.text),
                floor: 0, // Default, da nicht im Formular
                location: "Building ${_buildingIdController.text}",
                equipment: [], 
                currentStatus: RoomStatus.free, 
                estimatedWalkingTime: Duration.zero,
                confirmationCode: int.tryParse(_confirmationCodeController.text) ?? 0,
              );
              
              // Zurückgeben an Parent mit BuildingID
              widget.onSave(newRoom, int.parse(_buildingIdController.text));
            }
          },
          child: const Text("Erstellen"),
        )
      ],
    );
  }
}



// DIALOG ZUM BEARBEITEN
class _EditRoomDialog extends StatefulWidget {
  final Room room;
  final Function(Room) onSave;

  const _EditRoomDialog({required this.room, required this.onSave});

  @override
  State<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<_EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller initialisieren wir gleich mit den Werten aus dem existierenden Raum
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
    _buildingIdController = TextEditingController(text: widget.room.rawBuildingId?.toString() ?? "1");
    _descriptionController = TextEditingController(text: widget.room.description);
    _confirmationCodeController = TextEditingController(text: widget.room.confirmationCode.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Raum bearbeiten: ${widget.room.name}"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Raum Name"),
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: "Raum Nummer"),
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Kapazität"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Beschreibung"),
              ),
              TextFormField(
                controller: _confirmationCodeController,
                decoration: const InputDecoration(labelText: "Bestätigungscode (4-stellig)"),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Pflichtfeld";
                  if (v.length != 4) return "Muss 4-stellig sein";
                  if (int.tryParse(v) == null) return "Nur Zahlen erlaubt";
                  return null;
                },
              ),
              TextFormField(
                controller: _buildingIdController,
                decoration: const InputDecoration(labelText: "Building ID"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Wir erstellen einen neuen Room mit den geänderten Daten
              // WICHTIG: Die ID muss gleich bleiben!
              final updatedRoom = Room(
                id: widget.room.id, // ID behalten!
                name: _nameController.text,
                roomNumber: _numberController.text,
                capacity: int.parse(_capacityController.text),
                floor: widget.room.floor,
                location: widget.room.location,
                equipment: widget.room.equipment, // Equipment lassen wir erst mal gleich
                currentStatus: widget.room.currentStatus,
                estimatedWalkingTime: widget.room.estimatedWalkingTime,
                rawBuildingId: int.tryParse(_buildingIdController.text),
                description: _descriptionController.text,
                confirmationCode: int.tryParse(_confirmationCodeController.text) ?? 0,
              );
              
              widget.onSave(updatedRoom);
            }
          },
          child: const Text("Speichern"),
        )
      ],
    );
  }
}