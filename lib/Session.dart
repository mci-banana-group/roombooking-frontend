import 'package:flutter/material.dart';
import 'package:mci_booking_app/Models/Enums/user_role.dart';
import 'Models/user.dart';

class Session extends ChangeNotifier {
  User? currentUser;

  bool get authenticated => currentUser != null;
  bool get isAdmin => currentUser?.role == UserRole.admin;

  // Login with cached credentials
  // Returns true on success, false on no credentials saved / no success
  Future<bool> performCachedLogin() async {
    // ToDo: login
    await Future.delayed(Duration(seconds: 2));

    // For going to login screen -> false
    // For going to Home Screen -> true

    return false;
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
