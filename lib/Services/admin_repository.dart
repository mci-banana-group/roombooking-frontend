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


  AdminRepository(this._ref);

  Future<bool> createRoom(Room room, int buildingId) async {
    final url = Uri.parse('${API.base_url}${API.adminRooms}');
    
    // Token holen
    final session = _ref.read(sessionProvider);
    final token = session.token ?? "";


    // Mapping: Frontend-Model -> Swagger Request Body
    final Map<String, dynamic> requestBody = {
      "name": room.name,
      "roomNumber": int.tryParse(room.roomNumber) ?? 0, // Backend accepts integer
      "capacity": room.capacity,
      "buildingId": buildingId, // WICHTIG: Das erwartet Swagger
      
      // Felder, die Swagger will, aber wir im Frontend-Model (noch) nicht haben:
      "description": room.name, 
      "status": "FREE", // Enum value expected by backend (FREE, RESERVED, OCCUPIED)
      "confirmationCode": "0000", 
      
      // Equipment mappen
      "equipment": room.equipment.map((e) => {
        "type": e.type.apiValue, // Use apiValue (e.g. BEAMER) instead of displayName
        "quantity": e.quantity,
        "description": e.description ?? ""
      }).toList(),
    };

    try {
      print('DEBUG AdminRepository: Sending create room request to $url');
      print('DEBUG AdminRepository: Payload: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      print('DEBUG AdminRepository: Response status: ${response.statusCode}');
      print('DEBUG AdminRepository: Response body: ${response.body}');

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
    // Hier später GET /rooms implementieren
    return [];
  }
}