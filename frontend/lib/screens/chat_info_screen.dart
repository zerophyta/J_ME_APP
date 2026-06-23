import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ChatInfoScreen extends StatefulWidget {
  final int chatId;
  const ChatInfoScreen({super.key, required this.chatId});

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  final ApiClient api = ApiClient();
  Map<String, dynamic> chatInfo = {};
  bool muted = false;

  @override
  void initState() {
    super.initState();
    _loadChatInfo();
  }

  Future<void> _loadChatInfo() async {
    final data = await api.getChatInfo(widget.chatId);
    setState(() {
      chatInfo = data;
      muted = data["muted"] ?? false;
    });
  }

  Future<void> _toggleMute(bool val) async {
    bool success = await api.setMute(widget.chatId, val);
    if (success) setState(() => muted = val);
  }

  @override
  Widget build(BuildContext context) {
    if (chatInfo.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Info")),
      body: ListView(
        children: [
          // Profile Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chatInfo["avatar"]),
              radius: 30,
            ),
            title: Text(chatInfo["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Members: ${chatInfo["members_count"]}"),
          ),
          const Divider(),

          // Media/Docs Preview
          ListTile(
            leading: const Icon(Icons.image, color: Colors.amber),
            title: const Text("Media, Links & Docs"),
            onTap: () => Navigator.pushNamed(context, "/media", arguments: widget.chatId),
          ),

          // Mute Notifications
          SwitchListTile(
            title: const Text("Mute Notifications"),
            value: muted,
            onChanged: _toggleMute,
          ),

          // Encryption Info
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.blue),
            title: const Text("Encryption"),
            subtitle: const Text("Messages are end-to-end encrypted"),
          ),

          // Shortcuts
          ListTile(
            leading: const Icon(Icons.wallpaper, color: Colors.green),
            title: const Text("Chat Wallpaper"),
            onTap: () => Navigator.pushNamed(context, "/appearance"),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.purple),
            title: const Text("Search in Chat"),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Clear Chat"),
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.redAccent),
            title: const Text("Block / Report"),
          ),
        ],
      ),
    );
  }
}
