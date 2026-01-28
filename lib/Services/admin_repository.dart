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

  // 1. CREATE ROOM
  Future<bool> createRoom(Room room, int buildingId) async {
    final url = Uri.parse('${API.base_url}${API.adminRooms}');
    
    final session = _ref.read(sessionProvider);
    final token = session.token ?? "";

    // SICHERHEITS-BODY
    final Map<String, dynamic> requestBody = {
      "name": room.name.isEmpty ? "Test Room" : room.name,
      "roomNumber": int.tryParse(room.roomNumber) ?? 0,
      "capacity": room.capacity,
      "buildingId": buildingId, 
      "description": "room created via app",
      "status": "FREE",         
      "confirmationCode": "000",   
      "equipment": []
    };

    try {
      print('DEBUG AdminRepository: Sending create room request to $url');
      print('DEBUG AdminRepository: Payload: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      print('DEBUG AdminRepository: Response status: ${response.statusCode}');
      print('DEBUG AdminRepository: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;

    } catch (e) {
      print("CRASH Create: $e");
      return false;
    }
  }

  //2. DELETE ROOM
  Future<bool> deleteRoom(String roomId) async {
    final url = Uri.parse('${API.base_url}${API.adminRooms}/$roomId');
    
    final session = _ref.read(sessionProvider);
    final token = session.token;

    if (token == null) return false;

    try {
      print("Lösche Raum ID: $roomId");
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Delete Status: ${response.statusCode}");
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      print("Fehler beim Löschen: $e");
      return false;
    }
  }

  //3. UPDATE ROOM
  Future<bool> updateRoom(String roomId, Room updatedRoom) async {
    final url = Uri.parse('${API.base_url}${API.adminRooms}/$roomId');
    
    final session = _ref.read(sessionProvider);
    final token = session.token;

    if (token == null) return false;

    final Map<String, dynamic> requestBody = {
      "name": updatedRoom.name,
      "roomNumber": int.tryParse(updatedRoom.roomNumber) ?? 999,
      "capacity": updatedRoom.capacity,
      "buildingId": updatedRoom.rawBuildingId ?? 1,
      "description": "Updated via App",
      "status": "FREE", 
      "confirmationCode": "000",
      "equipment": []//updatedRoom.equipment.map((e) => {
        //"type": "WHITEBOARD", 
        //"quantity": 1,
        //"description": ""
      //}).toList(),
    };

    try {
      print("Update Raum ID: $roomId");
      print("DEBUG Update: Sende an $url");
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("Update Status: ${response.statusCode}");
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      }
      print("DEBUG Update FEHLER BODY: ${response.body}");
      return false;
    } catch (e) {
      print("Fehler beim Update: $e");
      return false;
    }
  }

  // 4. GET ALL ROOMS
  Future<List<Room>> getAllRooms() async {
    final session = _ref.read(sessionProvider);
    List<Room> allRooms = [];

    try {
      final buildings = await session.getBuildings();
      
      for (var b in buildings) {
        final bId = b['id'];
        // Ruft Räume pro Gebäude ab
        final roomData = await session.getRooms(buildingId: bId);
        
        // Wandelt JSON in Room Objekte um und fügt sie der Liste hinzu
        allRooms.addAll(roomData.map((json) => Room.fromJson(json)).toList());
      }
      
      return allRooms;
    } catch (e) {
      print("Fehler beim Laden der Räume: $e");
      return [];
    }
  }
}