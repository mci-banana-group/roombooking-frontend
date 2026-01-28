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

  // --- HIER PASSIERT DIE MAGIE VOM BACKEND ZUR APP (GET) ---
  factory Room.fromJson(Map<String, dynamic> json) {
    // 1. DAS PÄCKCHEN AUSPACKEN
    // Der Server verpackt die Infos im Key "room".
    // Wir prüfen: Gibt es "room"? Wenn ja, nehmen wir das. Sonst nehmen wir json direkt.
    final Map<String, dynamic> data = (json['room'] != null && json['room'] is Map<String, dynamic>) 
        ? json['room'] 
        : json;

    // Hilfsfunktion um Zahlen sicher zu lesen
    int readInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    // 2. Building auslesen
    // Laut Screenshot liegt "building" NEBEN "room" (also im originalen json), nicht darin.
    String locationName = "Unknown";
    int bId = 1;
    
    // Wir schauen erst im Haupt-JSON
    if (json['building'] != null && json['building'] is Map) {
      locationName = json['building']['name'] ?? "Unknown";
      bId = json['building']['id'] ?? 1;
    } 
    // Fallback: Manchmal ist building auch im room-Objekt
    else if (data['building'] != null && data['building'] is Map) {
      locationName = data['building']['name'] ?? "Unknown";
      bId = data['building']['id'] ?? 1;
    }

    return Room(
      // WICHTIG: Wir nutzen jetzt 'data' statt 'json' für die Raum-Details!
      id: data['id']?.toString() ?? '', 
      
      name: data['name'] ?? 'Unnamed', // Jetzt sollte hier "Seminar Room A" stehen
      roomNumber: data['roomNumber']?.toString() ?? '',
      capacity: readInt(data['capacity']),
      
      floor: readInt(data['floor']), 
      location: locationName, 
      
      rawBuildingId: bId,

      equipment: (data['equipment'] as List<dynamic>?)
              ?.map((e) => RoomEquipment.fromJson(e))
              .toList() ?? [],
              
      // Status parsen
      currentStatus: _parseStatus(data['status']),
      
      estimatedWalkingTime: const Duration(minutes: 0),
    );
  }

  static RoomStatus _parseStatus(String? status) {
    if (status == null) return RoomStatus.free;
    // Dein Screenshot zeigte "FREE" als Status -> das müssen wir abfangen!
    switch (status.toUpperCase()) {
      case 'OCCUPIED': return RoomStatus.occupied;
      case 'AVAILABLE': 
      case 'FREE':      // <--- Das hier hat gefehlt!
        return RoomStatus.free;
      default: return RoomStatus.free;
    }
  }
}