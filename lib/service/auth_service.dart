import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool isLoggedIn = false;

  void login(String username, String password, BuildContext context) {
    if (username == "admin" && password == "password") {
      isLoggedIn = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text("Success"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text("Error"),
        ),
      );
    }

    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}
