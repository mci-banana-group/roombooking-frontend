import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mci_booking_app/Models/Enums/user_role.dart';
import 'Models/user.dart';
import 'Models/auth_models.dart';
import 'Services/auth_service.dart';

class Session extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserResponse? currentUser;

  bool get authenticated => currentUser != null;
  bool get isAdmin =>
      currentUser?.isAdmin ?? false; // Use isAdmin field from backend
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get token => _authService.token;

  // Login with cached credentials
  // Returns true on success, false on no credentials saved / no success
  Future<bool> performCachedLogin() async {
    // Check if we have a saved session
    if (_authService.currentUser != null) {
      currentUser = _authService.currentUser;
      return true;
    }
    return false;
  }

  // Login with credentials
  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      currentUser = _authService.currentUser;
    }
    return success;
  }

  // Register new user
  Future<bool> register(RegistrationRequest request) async {
    final success = await _authService.register(request);
    if (success) {
      // Auto login after registration
      final email = request.email;
      final password = request.password;
      await login(email, password);
    }
    return success;
  }

  // Check in to a booking
  Future<bool> checkIn(int bookingId, String code) async {
    final success = await _authService.checkIn(bookingId, code);
    if (success) {
      currentUser = _authService.currentUser;
    }
    return success;
  }

  // Get bookings for current user
  Future<List<dynamic>> getMyBookings() async {
    return _authService.getMyBookings();
  }

  // Create a new booking
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    final success = await _authService.createBooking(bookingData);
    if (success) {
      currentUser = _authService.currentUser;
    }
    return success;
  }

  // Update an existing booking
  Future<bool> updateBooking(
    int bookingId,
    Map<String, dynamic> bookingData,
  ) async {
    final success = await _authService.updateBooking(bookingId, bookingData);
    if (success) {
      currentUser = _authService.currentUser;
    }
    return success;
  }

  // Delete a booking
  Future<bool> deleteBooking(int bookingId) async {
    final success = await _authService.deleteBooking(bookingId);
    if (success) {
      currentUser = _authService.currentUser;
    }
    return success;
  }

  // Get all buildings
  Future<List<dynamic>> getBuildings() async {
    return _authService.getBuildings();
  }

  // Get all rooms with optional filters
  Future<List<dynamic>> getRooms({
    int? capacity,
    String? equipment,
    int? buildingId,
    String? date,
  }) async {
    return _authService.getRooms(
      capacity: capacity,
      equipment: equipment,
      buildingId: buildingId,
      date: date,
    );
  }
  
  // Get all rooms (ADMIN)
  Future<List<dynamic>> getAdminRooms() async {
    return _authService.getAdminRooms();
  }

  // Get room equipment
  Future<List<dynamic>> getRoomEquipment(int buildingId) async {
    return _authService.getRoomEquipment(buildingId);
  }

  void setCurrentUser(UserResponse? user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    _authService.clearSession();
    currentUser = null;
    notifyListeners();
  }

  // Check if token is expired
  bool get isTokenExpired => _authService.isTokenExpired;
}
