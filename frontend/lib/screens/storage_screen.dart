import 'package:flutter/material.dart';
import '../api/api_client.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final ApiClient api = ApiClient();
  Map<String, dynamic> usage = {};

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final data = await api.getStorageUsage();
    setState(() {
      usage = data;
    });
  }

  Future<void> _clearCache() async {
    bool success = await api.clearCache();
    if (success) _loadUsage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Storage & Data Usage")),
      body: usage.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text("Messages"),
                  trailing: Text("${usage["messages_size"]} MB"),
                ),
                ListTile(
                  title: const Text("Media"),
                  trailing: Text("${usage["media_size"]} MB"),
                ),
                ListTile(
                  title: const Text("Cache"),
                  trailing: Text("${usage["cache_size"]} MB"),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Auto-download Media"),
                  value: usage["auto_download"] ?? false,
                  onChanged: (val) async {
                    await api.setAutoDownload(val);
                    _loadUsage();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _clearCache,
                  child: const Text("Clear Cache"),
                ),
              ],
            ),
    );
  }
}
