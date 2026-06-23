import 'package:flutter/material.dart';
import '../api/api_client.dart';

class AdvancedPrivacyScreen extends StatefulWidget {
  const AdvancedPrivacyScreen({super.key});

  @override
  State<AdvancedPrivacyScreen> createState() => _AdvancedPrivacyScreenState();
}

class _AdvancedPrivacyScreenState extends State<AdvancedPrivacyScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> blockedUsers = [];
  bool allowForwarding = true;
  bool allowScreenshots = true;
  bool secretChatsEnabled = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    final data = await api.getAdvancedPrivacy();
    setState(() {
      blockedUsers = data["blocked_users"];
      allowForwarding = data["forwarding"];
      allowScreenshots = data["screenshots"];
      secretChatsEnabled = data["secret_chats"];
    });
  }

  Future<void> _savePrivacy() async {
    bool success = await api.setAdvancedPrivacy(
      allowForwarding,
      allowScreenshots,
      secretChatsEnabled,
    );
    setState(() {
      message = success ? "Advanced privacy updated ✅" : "Update failed ❌";
    });
  }

  Future<void> _unblockUser(int id) async {
    bool success = await api.unblockUser(id);
    if (success) {
      setState(() {
        blockedUsers.removeWhere((u) => u["id"] == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Advanced Privacy")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Allow Forwarding"),
            value: allowForwarding,
            onChanged: (val) => setState(() => allowForwarding = val),
          ),
          SwitchListTile(
            title: const Text("Allow Screenshots"),
            value: allowScreenshots,
            onChanged: (val) => setState(() => allowScreenshots = val),
          ),
          SwitchListTile(
            title: const Text("Enable Secret Chats"),
            value: secretChatsEnabled,
            onChanged: (val) => setState(() => secretChatsEnabled = val),
          ),
          const Divider(),
          ListTile(title: const Text("Blocked Users")),
          ...blockedUsers.map((user) => ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(user["name"]),
                trailing: IconButton(
                  icon: const Icon(Icons.undo, color: Colors.green),
                  onPressed: () => _unblockUser(user["id"]),
                ),
              )),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _savePrivacy, child: const Text("Save")),
          Center(child: Text(message)),
        ],
      ),
    );
  }
}
