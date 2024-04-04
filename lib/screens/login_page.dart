import 'package:cours_flutter_login_form/model/credential.dart';
import 'package:cours_flutter_login_form/screens/create_account_page.dart';
import 'package:cours_flutter_login_form/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Password"),
            ),
            const SizedBox(height: 12),
            OverflowBar(
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(),
                    ),
                  ),
                  child: const Text("Sign in"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _submitForm(authService),
                  child: const Text("Login"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submitForm(AuthService authService) async {
    var credential = Credential(
      email: _emailController.text,
      password: _passwordController.text,
    );

    authService.login(credential).then((message) {
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(message),
        ),
      );
    });
  }
}
