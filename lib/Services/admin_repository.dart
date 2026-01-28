import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../Models/room.dart';
import '../Session.dart';
import '../Resources/API.dart'; 
import '../main.dart';
import '../Helper/http_client.dart';


final adminRepositoryProvider = Provider((ref) => AdminRepository(ref));

class AdminRepository {
  final Ref _ref;
  final String baseUrl = "https://roombooking-backend-17kv.onrender.com";

  AdminRepository(this._ref);

Future<bool> createRoom(Room room, int buildingId) async {
    // URL laut Swagger
    final url = Uri.parse('$baseUrl/admin/rooms');
    
    // Wir nutzen die Session, die beim GET ja funktioniert
    final session = _ref.read(sessionProvider);
    final token = session.token;

    if (token == null) {
      print("ABBRUCH: Kein Token.");
      return false;
    }

    // --- SICHERHEITS-BODY ---
    // Wir ignorieren kurz das Formular und senden Daten, die 100% klappen müssen.
    // Damit schließen wir Tippfehler im UI aus.
    final Map<String, dynamic> requestBody = {
      "name": "Test Room Branch",
      "roomNumber": "999",
      "capacity": 10,
      "buildingId": buildingId, 
      "description": "Created via App",
      "status": "FREE",         
      "confirmationCode": "",   
      "equipment": [] // WICHTIG: Leer lassen!
    };

    try {
      print("Sende POST via HttpClient...");
      
      // HIER IST DER SCHLÜSSEL: Wir nutzen HttpClient!
      final response = await HttpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("Status: ${response.statusCode}");
      print("Antwort: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;

    } catch (e) {
      print("CRASH: $e");
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