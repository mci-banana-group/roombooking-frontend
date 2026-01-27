import 'package:flutter/material.dart';
import 'package:mci_booking_app/Models/Enums/user_role.dart';
import 'Models/user.dart';

class Session extends ChangeNotifier {
  User? currentUser;
  String? token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwOi8vMC4wLjAuMDo4MDgwIiwiaXNzIjoiaHR0cDovLzAuMC4wLjA6ODA4MCIsInVzZXJJZCI6MSwicGVybWlzc2lvbkxldmVsIjoiQURNSU4ifQ.YaXkDzKitzuRjBYwIPOPTGMRdiqy3gBOMSBVv-oIBuw";

  
  bool get authenticated => currentUser != null;

  
  bool get isAuthenticated => authenticated;

  //Admin Check
  bool get isAdmin => currentUser?.role == UserRole.admin;

  // Login with cached credentials
  // Returns true on success, false on no credentials saved / no success
  Future<bool> performCachedLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    return false; // aktuell: keine Cache-Login Logik
  }

  // Mock-Login (später ersetzt ihr das durch echtes Backend-Login)
  Future<bool> login(String emailOrUsername, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

   
    if (emailOrUsername.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    // Demo-Regel: wenn Username "admin" ist -> Admin, sonst normaler User
    final e = emailOrUsername.trim().toLowerCase();
    final role = (e == 'admin' || e.startsWith('admin@')) ? UserRole.admin : UserRole.user;

    setCurrentUser(User(id: 'local-1', name: emailOrUsername.trim(), role: role));
    return true;
  }

  void setCurrentUser(User? user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}

