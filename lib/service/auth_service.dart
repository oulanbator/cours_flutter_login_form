import 'dart:convert';

import 'package:cours_flutter_login_form/constants.dart';
import 'package:cours_flutter_login_form/model/auth_response.dart';
import 'package:cours_flutter_login_form/model/credential.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  bool isLoggedIn = false;

  final secureStorage = const FlutterSecureStorage();
  String? _accessToken;
  String? _accessTokenExpiration;
  String? _refreshToken;

  Future<String> login(Credential credential) async {
    var headers = {'Content-Type': 'application/json; charset=utf-8'};

    final response = await http.post(
      Uri.parse(Constants.uriAuthentification),
      headers: headers,
      body: jsonEncode(credential.toJson()),
    );

    if (response.statusCode == 200) {
      var authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _handleSuccessAuthResponse(authResponse);
      isLoggedIn = true;
      notifyListeners();
      return "Vous êtes connecté !";
    } else {
      return "Failed to login: ${response.statusCode}";
    }
  }

  Future<void> _handleSuccessAuthResponse(AuthResponse authResponse) async {
    // Set les variables dans auth manager
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;
    // La réponse nous donne le temps de validité du token,
    // Mais ce que nous souhaitons stocker c'est sa date d'expiration
    DateTime expirationTime =
        DateTime.now().add(Duration(milliseconds: authResponse.expires));
    _accessTokenExpiration = expirationTime.toString();

    // Store values dans secure storage
    await secureStorage.write(
      key: Constants.storageKeyAccessToken,
      value: _accessToken!,
    );
    await secureStorage.write(
      key: Constants.storageKeyTokenExpire,
      value: _accessTokenExpiration!,
    );
    await secureStorage.write(
      key: Constants.storageKeyRefreshToken,
      value: _refreshToken!,
    );
  }

  void logout() async {
    // Fait un call HTTP pour invalider les tokens
    var payload = {"refresh_token": _refreshToken!};
    await http.post(Uri.parse(Constants.uriLogout), body: json.encode(payload));
    // Clean variables dans AuthManager
    _accessToken = null;
    _accessTokenExpiration = null;
    _refreshToken = null;
    // Supprime les valeurs du secure storage
    await secureStorage.delete(key: Constants.storageKeyAccessToken);
    await secureStorage.delete(key: Constants.storageKeyTokenExpire);
    await secureStorage.delete(key: Constants.storageKeyRefreshToken);

    isLoggedIn = false;
    notifyListeners();
  }

  Future<Map<String, String>> getAuthenticatedHeaders() async {
    String accessToken = await _getAccessToken();
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=utf-8'
    };
  }

  Future<String> _getAccessToken() async {
    return _accessToken!;
  }
}
