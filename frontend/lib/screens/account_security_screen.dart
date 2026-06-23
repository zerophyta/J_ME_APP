import 'package:flutter/material.dart';
import '../api/api_client.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> loginHistory = [];
  bool twoFactorEnabled = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    _loadSecurity();
  }

  Future<void> _loadSecurity() async {
    final data = await api.getAccountSecurity();
    setState(() {
      loginHistory = data["logins"];
      twoFactorEnabled = data["two_factor"] ?? false;
    });
  }

  Future<void> _toggleTwoFactor(bool val) async {
    bool success = await api.setTwoFactor(val);
    if (success) {
      setState(() => twoFactorEnabled = val);
      setState(() => message = val ? "2FA enabled ✅" : "2FA disabled ❌");
    }
  }

  Future<void> _revokeAllDevices() async {
    bool success = await api.revokeAllDevices();
    setState(() {
      message = success ? "All devices revoked ✅" : "Failed to revoke ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Security")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Two-Factor Authentication"),
            value: twoFactorEnabled,
            onChanged: _toggleTwoFactor,
          ),
          const Divider(),
          ListTile(
            title: const Text("Login History"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: loginHistory.map((login) {
                return Text("${login["device"]} • ${login["location"]} • ${login["time"]}");
              }).toList(),
            ),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _revokeAllDevices,
            child: const Text("Revoke All Devices"),
          ),
          const SizedBox(height: 20),
          Center(child: Text(message)),
        ],
      ),
    );
  }
}
