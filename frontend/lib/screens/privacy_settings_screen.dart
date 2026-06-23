import 'package:flutter/material.dart';
import '../api/api_client.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final ApiClient api = ApiClient();
  String profileVisibility = "Everyone";
  String lastSeenVisibility = "Everyone";
  String statusVisibility = "Everyone";
  bool readReceipts = true;
  String message = "";

  Future<void> _savePrivacy() async {
    bool success = await api.setPrivacySettings(
      profileVisibility,
      lastSeenVisibility,
      statusVisibility,
      readReceipts,
    );
    setState(() {
      message = success ? "Privacy updated ✅" : "Update failed ❌";
    });
  }

  Widget _buildDropdown(String title, String value, List<String> options, Function(String) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Settings")),
      body: ListView(
        children: [
          _buildDropdown("Profile Photo Visibility", profileVisibility, ["Everyone", "My Contacts", "Nobody"],
              (val) => setState(() => profileVisibility = val)),
          _buildDropdown("Last Seen Visibility", lastSeenVisibility, ["Everyone", "My Contacts", "Nobody"],
              (val) => setState(() => lastSeenVisibility = val)),
          _buildDropdown("Status Visibility", statusVisibility, ["Everyone", "My Contacts", "Nobody"],
              (val) => setState(() => statusVisibility = val)),
          SwitchListTile(
            title: const Text("Send Read Receipts"),
            value: readReceipts,
            onChanged: (val) => setState(() => readReceipts = val),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _savePrivacy, child: const Text("Save")),
          Center(child: Text(message)),
        ],
      ),
    );
  }
}
