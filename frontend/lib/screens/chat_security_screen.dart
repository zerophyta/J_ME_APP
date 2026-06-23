import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ChatSecurityScreen extends StatefulWidget {
  final int chatId;
  const ChatSecurityScreen({super.key, required this.chatId});

  @override
  State<ChatSecurityScreen> createState() => _ChatSecurityScreenState();
}

class _ChatSecurityScreenState extends State<ChatSecurityScreen> {
  final ApiClient api = ApiClient();
  bool pinLockEnabled = false;
  bool fingerprintEnabled = false;
  bool twoFactorEnabled = false;
  String message = "";

  Future<void> _saveSecurity() async {
    bool success = await api.setChatSecurity(
      widget.chatId,
      pinLockEnabled,
      fingerprintEnabled,
      twoFactorEnabled,
    );
    setState(() {
      message = success ? "Security updated ✅" : "Update failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Security")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Enable PIN Lock"),
              value: pinLockEnabled,
              onChanged: (val) => setState(() => pinLockEnabled = val),
            ),
            SwitchListTile(
              title: const Text("Enable Fingerprint Unlock"),
              value: fingerprintEnabled,
              onChanged: (val) => setState(() => fingerprintEnabled = val),
            ),
            SwitchListTile(
              title: const Text("Enable Two-Factor Authentication"),
              value: twoFactorEnabled,
              onChanged: (val) => setState(() => twoFactorEnabled = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSecurity, child: const Text("Save")),
            Text(message),
          ],
        ),
      ),
    );
  }
}
