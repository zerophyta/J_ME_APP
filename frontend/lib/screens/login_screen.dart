import 'package:flutter/material.dart';
import '../api/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiClient api = ApiClient();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> _login() async {
    bool success = await api.login(
      emailController.text,
      passwordController.text,
    );
    setState(() {
      message = success ? "Login successful ✅" : "Login failed ❌";
    });
    if (success) {
      Navigator.pushNamed(context, "/chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("J_ME Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            Text(message)
          ],
        ),
      ),
    );
  }
}

