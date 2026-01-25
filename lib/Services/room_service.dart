import 'dart:convert';
import '../Helper/http_client.dart';
import '../Resources/API.dart';
import '../Models/available_room.dart';
import '../Models/room.dart';
import '../Services/auth_service.dart';

class RoomService {
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  final AuthService _authService = AuthService();

  /// Get available rooms based on search criteria
  ///
  /// Parameters:
  /// - [date]: The date to search for available rooms (format: yyyy-MM-dd)
  /// - [startTime]: Start time in HH:mm format
  /// - [endTime]: End time in HH:mm format
  /// - [capacity]: Minimum capacity required
  /// - [buildingId]: Optional building ID filter
  /// - [equipment]: Optional list of required equipment
  Future<List<Room>> getAvailableRooms({
    required String date,
    required String startTime,
    required String endTime,
    required int capacity,
    int? buildingId,
    List<String>? equipment,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'capacity': capacity.toString(),
        'status': 'FREE',
      };

      if (buildingId != null) {
        queryParams['buildingId'] = buildingId.toString();
      }

      if (equipment != null && equipment.isNotEmpty) {
        queryParams['equipment'] = equipment.join(',');
      }

      final uri = Uri.parse('${API.base_url}${API.getRooms}').replace(queryParameters: queryParams);

      print('Fetching rooms from: $uri');

      final response = await HttpClient.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.token}', 'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) {
          // Some endpoints return: {"room": {...}, "bookings": []}
          // Others may return the room directly.
          final dynamic candidate = (json is Map<String, dynamic> && json.containsKey('room')) ? json['room'] : json;
          return Room.fromJson(candidate as Map<String, dynamic>);
        }).toList();
      } else {
        print('Failed to fetch rooms: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching available rooms: $e');
      return [];
    }
  }

  /// Get available rooms together with their bookings (API response: [{room: {...}, bookings: [...]}, ...]).
  Future<List<AvailableRoom>> getAvailableRoomsWithBookings({
    required String date,
    required String startTime,
    required String endTime,
    required int capacity,
    int? buildingId,
    List<String>? equipment,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'capacity': capacity.toString(),
        'status': 'FREE',
      };

      if (buildingId != null) {
        queryParams['buildingId'] = buildingId.toString();
      }

      if (equipment != null && equipment.isNotEmpty) {
        queryParams['equipment'] = equipment.join(',');
      }

      final uri = Uri.parse('${API.base_url}${API.getRooms}').replace(queryParameters: queryParams);

      final response = await HttpClient.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.token}', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.whereType<Map>().map((json) => AvailableRoom.fromJson(json.cast<String, dynamic>())).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching available rooms with bookings: $e');
      return [];
    }
  }

  /// Get all rooms without filters
  Future<List<Room>> getAllRooms() async {
    try {
      final uri = Uri.parse('${API.base_url}${API.getRooms}');

      final response = await HttpClient.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.token}', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          final dynamic candidate = (json is Map<String, dynamic> && json.containsKey('room')) ? json['room'] : json;
          return Room.fromJson(candidate as Map<String, dynamic>);
        }).toList();
      } else {
        print('Failed to fetch all rooms: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching all rooms: $e');
      return [];
    }
  }

  /// Get room by ID
  Future<Room?> getRoomById(String roomId) async {
    try {
      final uri = Uri.parse('${API.base_url}${API.getRooms}/$roomId');

      final response = await HttpClient.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.token}', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Room.fromJson(data);
      } else {
        print('Failed to fetch room: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching room by ID: $e');
      return null;
    }
  }

  /// Get buildings list
  Future<List<Map<String, dynamic>>> getBuildings() async {
    try {
      final uri = Uri.parse('${API.base_url}${API.getBuildings}');

      final response = await HttpClient.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.token}', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch buildings: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching buildings: $e');
      return [];
    }
  }

  /// Get room equipment for a specific building
  Future<List<Map<String, dynamic>>> getRoomEquipment(int buildingId) async {
    try {
      final uri = Uri.parse(
        '${API.base_url}${API.getRoomEquipment}',
      ).replace(queryParameters: {'buildingId': buildingId.toString()});

      final response = await HttpClient.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.token}', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch room equipment: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching room equipment: $e');
      return [];
    }
  }
}
