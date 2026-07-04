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

  String message = ""; // <-- lazima utangaze hii

  Future<void> _signup() async {
  final result = await api.createUser(
    nameController.text,
    emailController.text,
    passwordController.text,
  );

  // mfano: kama result ni Map
  bool success = result["success"] == true;

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
      appBar: AppBar(title: const Text("Signup")),
      body: Column(
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(hintText: "Name")),
          TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email")),
          TextField(controller: passwordController, decoration: const InputDecoration(hintText: "Password")),
          ElevatedButton(onPressed: _signup, child: const Text("Signup")),
          Text(message), // onyesha feedback
        ],
      ),
    );
  }
}
