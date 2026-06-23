import 'package:flutter/material.dart';
import '../api/api_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiClient api = ApiClient();

  bool notificationsEnabled = true;
  bool darkTheme = true;
  String username = "Jaram";
  String message = "";

  Future<void> _saveSettings() async {
    bool success = await api.setSettings(
      notificationsEnabled,
      darkTheme,
      username,
    );
    setState(() {
      message = success ? "Settings updated ✅" : "Update failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Username"),
              onChanged: (val) => setState(() => username = val),
            ),
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: notificationsEnabled,
              onChanged: (val) => setState(() => notificationsEnabled = val),
            ),
            SwitchListTile(
              title: const Text("Dark Theme"),
              value: darkTheme,
              onChanged: (val) => setState(() => darkTheme = val),
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
