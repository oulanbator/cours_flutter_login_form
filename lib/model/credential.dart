class Credential {
  final String email;
  final String password;

  Credential({required this.email, required this.password});

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}
