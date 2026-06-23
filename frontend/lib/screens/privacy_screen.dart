import 'package:flutter/material.dart';
import '../api/api_client.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ApiClient api = ApiClient();

  bool lastSeenVisible = true;
  bool profilePhotoVisible = true;
  bool readReceiptsEnabled = true;
  String message = "";

  Future<void> _saveSettings() async {
    bool success = await api.setPrivacy(
      lastSeenVisible,
      profilePhotoVisible,
      readReceiptsEnabled,
    );
    setState(() {
      message = success ? "Privacy updated ✅" : "Update failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Show Last Seen"),
              value: lastSeenVisible,
              onChanged: (val) => setState(() => lastSeenVisible = val),
            ),
            SwitchListTile(
              title: const Text("Show Profile Photo"),
              value: profilePhotoVisible,
              onChanged: (val) => setState(() => profilePhotoVisible = val),
            ),
            SwitchListTile(
              title: const Text("Enable Read Receipts"),
              value: readReceiptsEnabled,
              onChanged: (val) => setState(() => readReceiptsEnabled = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: const Text("Save")),
            Text(message)
          ],
        ),
      ),
    );
  }
}
