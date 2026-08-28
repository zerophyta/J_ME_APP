import 'package:flutter/material.dart';
import '../api/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiClient api = ApiClient();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> _login() async {
    bool success = await api.login(
      identifierController.text,
      passwordController.text,
    );
    setState(() {
      message = success ? "Login successful " : "Login failed ";
    });
    if (success) {
      Navigator.pushNamed(context, "/chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("J_ME Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Welcome back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text("Sign in to continue to J_ME", style: TextStyle(color: Color(0xFFB8C8DB))),
                const SizedBox(height: 22),
                TextField(controller: identifierController, decoration: const InputDecoration(labelText: "Username or  Email")),
                const SizedBox(height: 12),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                const SizedBox(height: 22),
                ElevatedButton(onPressed: _login, child: const Text("Login")),
                const SizedBox(height: 12),
                Center(child: Text(message)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

