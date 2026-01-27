import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mci_booking_app/Models/Enums/user_role.dart';
import 'Models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Session extends ChangeNotifier {
  User? currentUser;
  String? token;

  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => currentUser?.role == UserRole.admin;

  
  Future<bool> login(String email, String password) async {
    
    final url = Uri.parse("https://roombooking-backend-17kv.onrender.com/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password
        }),
      );

      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

          // Token speichern
        this.token = data['token'];
        
        // User Daten auslesen
        final userData = data['user'];
        
        // Rolle prüfen 
        final roleString = userData['role']?.toString().toUpperCase() ?? "USER";
        final isUserAdmin = roleString == "ADMIN" || roleString == "STAFF";

        // User im State speichern
        setCurrentUser(User(
          id: userData['id'].toString(),
          name: "${userData['firstName']} ${userData['lastName']}",
          role: isUserAdmin ? UserRole.admin : UserRole.user,
        ));

        return true; // Login erfolgreich
      } else {
        print("Login fehlgeschlagen: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Login Fehler (Netzwerk?): $e");
      return false;
    }
  }

  Future<bool> performCachedLogin() async {
    return false;
  }


  void setCurrentUser(User? user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    token = null;
    notifyListeners();
  }
}

