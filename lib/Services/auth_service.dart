import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/API.dart';
import '../Models/auth_models.dart';
import '../Helper/http_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final String _tokenKey = 'auth_token';
  late final String _userIdKey = 'user_id';
  late final String _userRoleKey = 'user_role';
  late final String _userFirstNameKey = 'user_first_name';
  late final String _userLastNameKey = 'user_last_name';
  late final String _userEmailKey = 'user_email';
  late final String _userIsAdminKey = 'user_is_admin';

  String? _token;
  UserResponse? _currentUser;

  String? get token => _token;
  UserResponse? get currentUser => _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _token != null && _currentUser != null;

  // Save token and user data
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(UserResponse user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id);
    await prefs.setString(_userRoleKey, user.role); // role is already a String
    await prefs.setString(_userFirstNameKey, user.firstName);
    await prefs.setString(_userLastNameKey, user.lastName);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setBool(_userIsAdminKey, user.isAdmin);
  }

  // Load token and user from storage
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    final userId = prefs.getInt(_userIdKey);

    if (userId != null) {
      _currentUser = UserResponse(
        id: userId,
        firstName: prefs.getString(_userFirstNameKey) ?? '',
        lastName: prefs.getString(_userLastNameKey) ?? '',
        email: prefs.getString(_userEmailKey) ?? '',
        role: prefs.getString(_userRoleKey) ?? 'STUDENT',
        isAdmin: prefs.getBool(_userIsAdminKey) ?? false,
      );
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      final url = '${API.base_url}${API.loginUser}';
      print('Login URL: $url');

      final requestBody = jsonEncode(LoginRequest(email: email, password: password).toJson());
      print('Request body: $requestBody');

      final response = await HttpClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        _token = loginResponse.token;
        _currentUser = loginResponse.user;
        await _saveToken(loginResponse.token);
        await _saveUser(loginResponse.user);
        return true;
      } else {
        print('Login failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Register new user
  Future<bool> register(RegistrationRequest request) async {
    try {
      final response = await HttpClient.post(
        Uri.parse('${API.base_url}${API.registerUser}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Check in to a booking
  Future<bool> checkIn(int bookingId, String code) async {
    try {
      final response = await HttpClient.post(
        Uri.parse('${API.base_url}${API.checkInBooking}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(CheckInRequest(bookingId: bookingId, code: code).toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Check-in error: $e');
      return false;
    }
  }

  // Get bookings for current user
  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await HttpClient.get(
        Uri.parse('${API.base_url}${API.getBookings}'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      print('Get bookings error: $e');
      return [];
    }
  }

  // Create a new booking
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await HttpClient.post(
        Uri.parse('${API.base_url}${API.createBooking}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(bookingData),
      );
      print(response.body);

      return response.statusCode == 201;
    } catch (e) {
      print('Create booking error: $e');
      return false;
    }
  }

  // Update an existing booking
  Future<bool> updateBooking(int bookingId, Map<String, dynamic> bookingData) async {
    try {
      final response = await HttpClient.put(
        Uri.parse('${API.base_url}${API.updateBooking}/$bookingId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(bookingData),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('Update booking error: $e');
      return false;
    }
  }

  // Delete a booking
  Future<bool> deleteBooking(int bookingId) async {
    try {
      final response = await HttpClient.delete(
        Uri.parse('${API.base_url}${API.deleteBooking}/$bookingId'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Delete booking error: $e');
      return false;
    }
  }

  // Get all buildings
  Future<List<dynamic>> getBuildings() async {
    try {
      final response = await HttpClient.get(
        Uri.parse('${API.base_url}${API.getBuildings}'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      print('Get buildings error: $e');
      return [];
    }
  }

  // Get all rooms with optional filters
  Future<List<dynamic>> getRooms({int? capacity, String? equipment, int? buildingId, String? date}) async {
    try {
      var uri = Uri.parse('${API.base_url}${API.getRooms}?');
      if (capacity != null) {
        uri = uri.replace(queryParameters: {'capacity': capacity.toString()});
      }
      if (equipment != null) {
        uri = uri.replace(queryParameters: {'equipment': equipment});
      }
      if (buildingId != null) {
        uri = uri.replace(queryParameters: {'buildingId': buildingId.toString()});
      }
      if (date != null) {
        uri = uri.replace(queryParameters: {'date': date});
      }

      final response = await HttpClient.get(uri, headers: {'Authorization': 'Bearer $_token'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      print('Get rooms error: $e');
      return [];
    }
  }

  // Get room equipment
  Future<List<dynamic>> getRoomEquipment(int buildingId) async {
    try {
      final response = await HttpClient.get(
        Uri.parse('${API.base_url}${API.getRoomEquipment}?buildingId=$buildingId'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      print('Get room equipment error: $e');
      return [];
    }
  }

  // Clear user session
  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userFirstNameKey);
    await prefs.remove(_userLastNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userIsAdminKey);
  }

  // Check if token is expired
  bool get isTokenExpired {
    // In a real implementation, you would check the token expiration time
    // For now, we'll just check if we have a token
    return _token == null;
  }

  // Initialize the service by loading saved session
  Future<bool> init() async {
    await _loadToken();
    return _currentUser != null;
  }
}
