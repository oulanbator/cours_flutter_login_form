import 'package:cours_flutter_login_form/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Password"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _submitForm(),
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    var authService = Provider.of<AuthService>(context, listen: false);

    var username = usernameController.text;
    var password = passwordController.text;
    authService.login(username, password, context);
  }
}
