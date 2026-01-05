import 'package:flutter/material.dart';

import 'Models/user.dart';

class Session extends ChangeNotifier {
  User? currentUser;

  bool get authenticated => currentUser != null;

  // Login with cached credentials
  // Returns true on success, false on no credentials saved / no success
  Future<bool> performCachedLogin() async {
    // ToDo: login
    await Future.delayed(Duration(seconds: 2));
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
