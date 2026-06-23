import 'package:flutter/material.dart';
import '../api/api_client.dart';

class DeviceSecurityScreen extends StatefulWidget {
  const DeviceSecurityScreen({super.key});

  @override
  State<DeviceSecurityScreen> createState() => _DeviceSecurityScreenState();
}

class _DeviceSecurityScreenState extends State<DeviceSecurityScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final data = await api.getActiveDevices();
    setState(() {
      devices = data;
    });
  }

  Future<void> _revokeDevice(int deviceId) async {
    bool success = await api.revokeDevice(deviceId);
    if (success) {
      setState(() {
        devices.removeWhere((d) => d["id"] == deviceId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Security")),
      body: devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final device = devices[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.devices, color: Color(0xFFD4AF37)), // gold accent
                    title: Text("${device["name"]} (${device["platform"]})"),
                    subtitle: Text("Last active: ${device["last_active"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () => _revokeDevice(device["id"]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
