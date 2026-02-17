import 'dart:convert';
import '../Helper/http_client.dart';
import '../Resources/API.dart';
import '../Models/building.dart';
import '../Services/auth_service.dart';

class BuildingService {
  static final BuildingService _instance = BuildingService._internal();

  factory BuildingService() => _instance;

  BuildingService._internal();

  final AuthService _authService = AuthService();

// Cache for buildings to avoid repeated API calls
  List<Building>? _cachedBuildings;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Get all buildings from the API
  ///
  /// Returns a list of buildings. Results are cached for 30 minutes.
  /// Set [forceRefresh] to true to bypass the cache.
  Future<List<Building>> getBuildings({bool forceRefresh = false}) async {
    try {
// Check if we have valid cached data
      if (!forceRefresh && _cachedBuildings != null && _cacheTime != null) {
        if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
          print('Returning cached buildings');
          return _cachedBuildings!;
        }
      }


      final uri = Uri.parse('${API.base_url}${API.getBuildings}');

      print('Fetching buildings from: $uri');

      final response = await HttpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json'
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Convert JSON to Building objects
        _cachedBuildings = data
            .map((json) => Building.fromJson(json as Map<String, dynamic>))
            .toList();

        // Update cache time
        _cacheTime = DateTime.now();

        print('Successfully fetched ${_cachedBuildings!.length} buildings');
        return _cachedBuildings!;
      } else {
        print('Failed to fetch buildings: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching buildings: $e');
      return [];
    }

  }

  /// Get a specific building by ID
  Future<Building?> getBuildingById(int buildingId) async {
    try {
// Try to find in cached data first
      if (_cachedBuildings != null) {
        final building = _cachedBuildings!.firstWhere(
              (b) => b.id == buildingId,
          orElse: () => Building(id: -1, name: ''),
        );
        if (building.id != -1) {
          return building;
        }
      }


      final uri = Uri.parse('${API.base_url}${API.getBuildings}/$buildingId');

      final response = await HttpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Building.fromJson(data);
      } else {
        print('Failed to fetch building: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching building by ID: $e');
      return null;
    }

  }

  /// Clear the cached buildings
  void clearCache() {
    _cachedBuildings = null;
    _cacheTime = null;
    print('Buildings cache cleared');
  }

  /// Check if cache is still valid
  bool get isCacheValid {
    if (_cachedBuildings == null || _cacheTime == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }
}