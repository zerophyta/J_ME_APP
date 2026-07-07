import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/ws_client.dart';

class SecretChatScreen extends StatefulWidget {
  final int chatId;
  final int userId;

  const SecretChatScreen({super.key, required this.chatId, required this.userId});

  @override
  State<SecretChatScreen> createState() => _SecretChatScreenState();
}

class _SecretChatScreenState extends State<SecretChatScreen> {
  final ApiClient api = ApiClient();
  final WsClient ws = WsClient();
  final messageController = TextEditingController();

  List<dynamic> messages = [];
  int? selfDestructSeconds = 0;
  String message = "";

  @override
  void initState() {
    super.initState();
    ws.connect(userId: widget.userId);

    ws.stream.listen((event) {
      if (event["type"] == "secret:new_message") {
        setState(() {
          messages.add(event);
        });
        if (selfDestructSeconds != null && selfDestructSeconds! > 0) {
          Future.delayed(Duration(seconds: selfDestructSeconds!), () {
            setState(() {
              messages.remove(event);
            });
          });
        }
      }
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await api.getSecretMessages(widget.chatId);
    setState(() {
      messages = data;
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final success = await api.sendSecretMessage(
      widget.chatId,
      widget.userId,
      trimmedText,
      selfDestructSeconds ?? 0,
    );

    if (success) {
      ws.send({
        "type": "secret:new_message",
        "chat_id": widget.chatId,
        "sender_id": widget.userId,
        "content": trimmedText,
      });
      _loadMessages();
      setState(() {
        message = "Message sent ✅";
      });
      messageController.clear();
    } else {
      setState(() {
        message = "Failed ❌";
      });
    }
  }

  @override
  void dispose() {
    ws.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secret Chat"),
        actions: [
          PopupMenuButton<int>(
            onSelected: (val) => setState(() => selfDestructSeconds = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text("Self-Destruct: Off")),
              const PopupMenuItem(value: 5, child: Text("5 seconds")),
              const PopupMenuItem(value: 10, child: Text("10 seconds")),
              const PopupMenuItem(value: 30, child: Text("30 seconds")),
              const PopupMenuItem(value: 60, child: Text("1 minute")),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(msg["content"]),
                  subtitle: Text("From: ${msg["sender_id"]}"),
                  trailing: const Icon(Icons.lock, color: Colors.amber),
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFFD4AF37),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(hintText: "Type secret message..."),
                  ),
                ),
                IconButton(
                  onPressed: () => _sendMessage(messageController.text),
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(message),
          ),
        ],
      ),
    );
  }
}
