import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();
  String message = "";

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _signup() async {
    final result = await api.createUserMultipart(
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phone: phoneController.text.trim(),
      avatarFile: _avatarFile,
    );

    bool success = result["success"] == true;
    setState(() {
      message = success ? "Signup successful  " : "Signup failed ${result["message"]}";
    });

    if (success) {
      Navigator.pushNamed(context, "/chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar preview
            GestureDetector(
              onTap: () => _pickAvatar(ImageSource.gallery),
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _avatarFile != null ? FileImage(_avatarFile!) : null,
                child: _avatarFile == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _pickAvatar(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
                TextButton.icon(
                  onPressed: () => _pickAvatar(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form fields
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email Address"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _signup,
              child: const Text("Signup"),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
