import 'dart:convert';

import 'package:cours_flutter_login_form/constants.dart';
import 'package:cours_flutter_login_form/model/credential.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  bool isLoggedIn = false;

  Future<String> login(Credential credential) async {
    var headers = {'Content-Type': 'application/json; charset=utf-8'};

    final response = await http.post(
      Uri.parse(Constants.uriAuthentification),
      headers: headers,
      body: jsonEncode(credential.toJson()),
    );

    if (response.statusCode == 200) {
      isLoggedIn = true;
      notifyListeners();
      return "Vous êtes connecté !";
    } else {
      return "Failed to login: ${response.statusCode}";
    }
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}
