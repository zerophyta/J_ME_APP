import 'package:flutter/material.dart';
import '../api/api_client.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> logins = [];

  @override
  void initState() {
    super.initState();
    _loadLogins();
  }

  Future<void> _loadLogins() async {
    final data = await api.getLoginHistory();
    setState(() {
      logins = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login History")),
      body: logins.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: logins.length,
              itemBuilder: (_, i) {
                final login = logins[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.login, color: Color(0xFFD4AF37)), // gold accent
                    title: Text("${login["device"]} • ${login["os"]} • ${login["browser"]}"),
                    subtitle: Text("IP: ${login["ip"]} • ${login["location"]}\nTime: ${login["time"]}"),
                    trailing: login["current"]
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.history, color: Colors.blueGrey),
                  ),
                );
              },
            ),
    );
  }
}
