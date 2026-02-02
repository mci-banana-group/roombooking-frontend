import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mci_booking_app/Helper/http_client.dart';
import '../Models/room.dart';
import '../Models/booking.dart';
import '../Session.dart';
import '../Resources/API.dart'; 
import '../main.dart';
import '../Models/admin_stats.dart';
import '../Models/auth_models.dart';


final adminRepositoryProvider = Provider((ref) => AdminRepository(ref));

final allUsersProvider = FutureProvider.autoDispose<List<UserResponse>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getUsers();
});

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
      "confirmationCode": room.confirmationCode,   
      "equipment": room.equipment.map((e) => {
        "type": e.type.apiValue, 
        "quantity": e.quantity,
        "description": e.description ?? ""
      }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

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
      
      final response = await HttpClient.delete(
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

    final int? parsedRoomNumber = int.tryParse(updatedRoom.roomNumber);
    
    if (parsedRoomNumber == null) {
      print("Raumnummer '${updatedRoom.roomNumber}' ist keine gültige Zahl.");
      return false;
    }

    final Map<String, dynamic> requestBody = {
      "name": updatedRoom.name,
      "roomNumber": parsedRoomNumber,
      "capacity": updatedRoom.capacity,
      "buildingId": updatedRoom.building?.id ?? 1,
      "description": updatedRoom.description,
      "status": updatedRoom.currentStatus.name.toUpperCase(), 
      "confirmationCode": updatedRoom.confirmationCode,
      "equipment": updatedRoom.equipment.map((e) => {
        "type": e.type.apiValue, 
        "quantity": e.quantity,
        "description": e.description ?? ""
      }).toList(),
    };

    try {
      final response = await HttpClient.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );


      
      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      }
      return false;
    } catch (e) {
      print("Fehler beim Update: $e");
      return false;
    }
  }

  // 4. GET ALL ROOMS
  Future<List<Room>> getAllRooms() async {
    final session = _ref.read(sessionProvider);
    
    try {
      final roomData = await session.getAdminRooms();
      return roomData.map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      print("Fehler beim Laden der Admin-Räume: $e");
      return [];
    }
  }

  // 5. GET ADMIN STATS
  Future<AdminStats?> getStats({DateTime? start, DateTime? end}) async {
    String query = "";
    if (start != null && end != null) {
      //  Formatierung (ISO 8601)
      final s = start.toIso8601String().split('.').first;
      final e = end.toIso8601String().split('.').first;
      query = "?start=$s&end=$e";
    }

    final url = Uri.parse('${API.base_url}${API.adminStats}$query');
    
    final session = _ref.read(sessionProvider);
    final token = session.token;

    if (token == null) return null;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AdminStats.fromJson(data);
      }
      print("Stats Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("CRASH Stats: $e");
      return null;
    }
  }

  // 6. GET ROOM BOOKINGS
  Future<List<Booking>> getRoomBookings(String roomId, {DateTime? start, int? limit}) async {
    final startParam = (start ?? DateTime.now()).toUtc().toIso8601String();
    String query = "?from=$startParam";
    if (limit != null) {
      query += "&limit=$limit";
    }

    final url = Uri.parse('${API.base_url}${API.adminRooms}/$roomId/bookings$query');
    final session = _ref.read(sessionProvider);
    final token = session.token;

    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((b) => Booking.fromJson(b)).toList();
      }
      print("Error fetching bookings: ${response.statusCode} ${response.body}");
      return [];
    } catch (e) {
      print("Error fetching bookings for room $roomId: $e");
      return [];
    }
  }

  // 7. GET ALL USERS
  Future<List<UserResponse>> getUsers() async {
    final url = Uri.parse('${API.base_url}${API.adminUsers}');
    final session = _ref.read(sessionProvider);
    final token = session.token;

    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((u) => UserResponse.fromJson(u)).toList();
      }
      print("Error fetching users: ${response.statusCode} - ${response.body}");
      return [];
    } catch (e) {
      print("CRASH getUsers: $e");
      return [];
    }
  }
}