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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Preferences",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    decoration: const InputDecoration(labelText: "Username"),
                    onChanged: (val) => setState(() => username = val),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Enable Notifications"),
                    value: notificationsEnabled,
                    onChanged: (val) => setState(() => notificationsEnabled = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Dark Theme"),
                    value: darkTheme,
                    onChanged: (val) => setState(() => darkTheme = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _saveSettings, child: const Text("Save")),
                  const SizedBox(height: 12),
                  Center(child: Text(message)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
