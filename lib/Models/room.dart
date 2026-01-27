import 'Enums/room_status.dart';
import 'room_equipment.dart';
// import 'building.dart'; // Falls du das Building Model nutzen willst

class Room {
  final String id;
  final String name;
  final String roomNumber;
  final int capacity;
  final int floor;             // Backend sendet das evtl. nicht -> wir setzen Default 0
  final String location;       // Backend sendet "building" Objekt -> wir holen den Namen da raus
  final List<RoomEquipment> equipment;
  final RoomStatus currentStatus;
  final Duration estimatedWalkingTime; // Backend sendet das nicht -> Default 0
  
  // Neu: Wir merken uns die BuildingID für Updates, falls nötig
  final int? rawBuildingId; 

  const Room({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.capacity,
    required this.floor,
    required this.location,
    required this.equipment,
    required this.currentStatus,
    required this.estimatedWalkingTime,
    this.rawBuildingId,
  });

  // --- HIER PASSIERT DIE MAGIE FÜR DAS BACKEND (POST/PUT) ---
  Map<String, dynamic> toJson() {
    return {
      // Backend erwartet diese Felder laut Swagger "Request body":
      'name': name,
      'roomNumber': roomNumber, 
      'capacity': capacity,
      // WICHTIG: Wenn wir eine ID haben, nutzen wir sie, sonst Default 1
      'buildingId': rawBuildingId ?? 1, 
      'description': "App Created Room", // Pflichtfeld im Backend, aber nicht in deiner UI
      'status': currentStatus.toString().split('.').last, // "FREE" statt "RoomStatus.FREE"
      'confirmationCode': "", // Pflichtfeld im Backend
      'equipment': equipment.map((e) => e.toJson()).toList(),
    };
  }

  // --- HIER PASSIERT DIE MAGIE VOM BACKEND ZUR APP (GET) ---
  factory Room.fromJson(Map<String, dynamic> json) {
    // Hilfsfunktion um Zahlen sicher zu lesen
    int readInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    // Building auslesen (Swagger Antwort ist verschachtelt: "building": { "name": ... })
    String locationName = "Unknown";
    int bId = 1;
    if (json['building'] != null && json['building'] is Map) {
      locationName = json['building']['name'] ?? "Unknown";
      bId = json['building']['id'] ?? 1;
    }

    return Room(
      // Swagger ID ist int (z.B. 10), deine App will String. Wir wandeln um.
      id: json['id']?.toString() ?? '', 
      
      name: json['name'] ?? 'Unnamed',
      roomNumber: json['roomNumber']?.toString() ?? '',
      capacity: readInt(json['capacity']),
      
      // Felder die das Backend NICHT liefert -> Defaults setzen
      floor: readInt(json['floor']), 
      location: locationName, 
      
      rawBuildingId: bId,

      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => RoomEquipment.fromJson(e))
              .toList() ?? [],
              
      // Status String vom Backend ("AVAILABLE") in Enum wandeln
      currentStatus: _parseStatus(json['status']),
      
      estimatedWalkingTime: const Duration(minutes: 0), // Backend liefert das nicht
    );
  }

  static RoomStatus _parseStatus(String? status) {
    if (status == null) return RoomStatus.free;
    // Hier musst du prüfen wie dein Enum genau heißt vs was Swagger sendet
    // Swagger Beispiel sagt "string", oft ist es "AVAILABLE" oder "OCCUPIED"
    switch (status.toUpperCase()) {
      case 'OCCUPIED': return RoomStatus.occupied;
      case 'AVAILABLE': return RoomStatus.free; // oder wie dein Enum heißt
      default: return RoomStatus.free;
    }
  }
}