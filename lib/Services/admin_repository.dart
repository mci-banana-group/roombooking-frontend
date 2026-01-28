import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../Models/room.dart';
import '../Session.dart';
import '../Resources/API.dart'; 
import '../main.dart';


final adminRepositoryProvider = Provider((ref) => AdminRepository(ref));

class AdminRepository {
  final Ref _ref;
  final String baseUrl = "https://roombooking-backend-17kv.onrender.com";

  AdminRepository(this._ref);

  Future<bool> createRoom(Room room, int buildingId) async {
    final url = Uri.parse('$baseUrl/admin/rooms');
    
    // Token holen
    final session = _ref.read(sessionProvider);
    final token = session.token ?? "";


    // Mapping: Frontend-Model -> Swagger Request Body
    final Map<String, dynamic> requestBody = {
      "name": room.name,
      "roomNumber": room.roomNumber, // Backend scheint String zu akzeptieren laut Schema "string"
      "capacity": room.capacity,
      "buildingId": buildingId, //Das erwartet Swagger
      
      // Felder, die Swagger will, aber wir im Frontend-Model (noch) nicht haben:
      "description": "Created via Admin Dashboard", 
      "status": "AVAILABLE", // oder room.currentStatus.toString()
      "confirmationCode": "", 
      
      // Equipment mappen
      "equipment": room.equipment.map((e) => {
        "type": "Whiteboard", // Annahme: Dein EquipmentModel hat 'name' oder 'type'
        "quantity": 1,   // Default, falls du keine Anzahl hast
        "description": ""
      }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Fehler Backend: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  // Hilfsmethode um Räume zu laden (GET)
  Future<List<Room>> getAllRooms() async {
    final session = _ref.read(sessionProvider);
    List<Room> allRooms = [];

    try {
      print("Strategie 1: Versuche ALLE Räume auf einmal zu laden...");
      // Versuch 1: Globaler Abruf via Session (AuthService)
      final List<dynamic> rawData = await session.getRooms();
      
      if (rawData.isNotEmpty) {
        print("Treffer! Globaler Endpunkt hat funktioniert.");
        return rawData.map((json) => Room.fromJson(json)).toList();
      }
    } catch (e) {
      print("Strategie 1 fehlgeschlagen ($e). Versuche Strategie 2...");
    }

    // Strategie 2: Verschachtelung (Deine Vermutung!)
    // Wenn global nicht geht, laden wir Gebäude und dann die Räume pro Gebäude.
    try {
      print("Strategie 2: Lade Räume pro Gebäude (Nested)...");
      
      // 1. Gebäude holen
      final buildings = await session.getBuildings();
      
      for (var b in buildings) {
        final bId = b['id'];
        print("Lade Räume für Gebäude ID: $bId");
        
        // 2. Räume NUR für dieses Gebäude holen
        // Wir nutzen den Parameter buildingId, den AuthService anbietet
        final roomData = await session.getRooms(buildingId: bId);
        
        final roomsForBuilding = roomData.map((json) => Room.fromJson(json)).toList();
        allRooms.addAll(roomsForBuilding);
      }
      
      print("Fertig! Insgesamt ${allRooms.length} Räume über Loop gefunden.");
      return allRooms;

    } catch (e) {
      print("Auch Strategie 2 fehlgeschlagen: $e");
      return [];
    }
  }
}