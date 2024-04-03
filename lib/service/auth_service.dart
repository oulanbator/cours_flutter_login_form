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

  AuthService() {
    _initAuthService();
  }

  Future<void> _initAuthService() async {
    // Récupère les valeurs dans le storage
    _accessToken =
        await secureStorage.read(key: Constants.storageKeyAccessToken);
    _accessTokenExpiration =
        await secureStorage.read(key: Constants.storageKeyTokenExpire);
    _refreshToken =
        await secureStorage.read(key: Constants.storageKeyRefreshToken);

    // Si le token est valide, on peut modifier isLoggedIn et notifier les listeners
    if (_isTokenValid()) {
      isLoggedIn = true;
      notifyListeners();
    } else {
      // Sinon, essayer de rafraichir le token
      await _tryToRefreshTokenAndLogin();
    }
  }

  bool _isTokenValid() {
    // Si nous avons un token et une date d'expiration, vérifier si le token est encore valide
    if (_accessToken != null && _accessTokenExpiration != null) {
      final expirationTime = DateTime.parse(_accessTokenExpiration!);
      // Le token est valide si la date d'expiration est dans le futur
      return expirationTime.isAfter(DateTime.now());
    }
    // Sinon, renvoie false
    return false;
  }

  Future<void> _tryToRefreshTokenAndLogin() async {
    bool tokenRefreshed = await _tryToRefreshToken();
    if (tokenRefreshed) {
      isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> _tryToRefreshToken() async {
    bool success = false;
    final headers = {'Content-Type': 'application/json; charset=utf-8'};
    final body = {"refresh_token": _refreshToken!, "mode": "json"};

    final response = await http.post(
      Uri.parse(Constants.uriRefreshToken),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      var authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _handleSuccessAuthResponse(authResponse);
      success = true;
    }

    return success;
  }

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
    if (_isTokenValid()) {
      return _accessToken!;
    }
    // Si le token n'est pas valide, on essaie de refresh
    bool tokenRefreshed = await _tryToRefreshToken();
    if (tokenRefreshed) {
      return _accessToken!;
    }
    // Ce cas de figure ne devrais logiquement jamais arriver, mais si lorques
    // l'on essaie de récupérer des headers : le token n'est pas valide, et l'on
    // ne parvient pas à refresh. On devrait forcer la déconnexion.
    logout();
    return "";
  }
}
