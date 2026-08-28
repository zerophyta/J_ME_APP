import 'package:flutter/material.dart';
import '../api/api_client.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final ApiClient api = ApiClient();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String message = ""; // <-- lazima utangaze hii

  Future<void> _signup() async {
  final result = await api.createUser(
    usernameController.text,
    phoneController.text,
    emailController.text,
    passwordController.text,
  );

  // mfano: kama result ni Map
  bool success = result["success"] == true;

  setState(() {
    message = success ? "Signup successful " : "Signup failed ";
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
          TextField(controller: usernameController, decoration: const InputDecoration(hintText: "Username ")),
          TextField(controller: phoneController, decoration: const InputDecoration(hintText: "Phone Number")),
          TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email Address")),
          TextField(controller: passwordController, decoration: const InputDecoration(hintText: "Password"), obscureText: true),
          ElevatedButton(onPressed: _signup, child: const Text("Signup")),
          Text(message), // onyesha feedback
        ],
      ),
    );
  }
}
