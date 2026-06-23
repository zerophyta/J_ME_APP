import 'package:flutter/material.dart';
import '../api/api_client.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final ApiClient api = ApiClient();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> _signup() async {
    bool success = await api.createUser(
      nameController.text,
      emailController.text,
      passwordController.text,
    );
    setState(() {
      message = success ? "Signup successful ✅" : "Signup failed ❌";
    });
    if (success) {
      Navigator.pushNamed(context, "/chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("J_ME Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: const Text("Signup")),
            Text(message)
          ],
        ),
      ),
    );
  }
}
