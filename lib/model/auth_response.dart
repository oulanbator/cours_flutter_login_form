class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expires;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
  });

  AuthResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['data']['access_token'],
        refreshToken = json['data']['refresh_token'],
        expires = json['data']['expires'];
}
