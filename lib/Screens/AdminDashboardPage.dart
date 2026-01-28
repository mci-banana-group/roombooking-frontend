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
  // Variable um zu prüfen, ob wir gerade laden
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Sofort beim Starten die echten Daten holen
    _loadRooms();
  }

  // Diese Methode holt die Daten vom Server
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
                        trailing: Chip(
                          label: Text(room.currentStatus.name.toUpperCase()),
                          backgroundColor: room.currentStatus.name == 'free' ? Colors.green[100] : Colors.orange[100],
                          labelStyle: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// --- DER DIALOG ZUM ERSTELLEN ---

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
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Kapazität"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Pflichtfeld" : null,
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
