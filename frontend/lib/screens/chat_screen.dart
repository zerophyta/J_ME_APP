import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/ws_client.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int userId;
  final int receiverId;

  const ChatScreen({
    super.key,
    this.chatId = 1,
    this.userId = 1,
    this.receiverId = 2,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiClient api = ApiClient();
  final WsClient ws = WsClient();
  final messageController = TextEditingController();
  List<dynamic> messages = [];
  int? typingUser;

  @override
  void initState() {
    super.initState();
    ws.connectUser(userId: widget.userId);

    // Sikiliza events kutoka websocket
    ws.stream.listen((event) {
      if (event["type"] == "direct_message") {
        setState(() => messages.add(event));
      } else if (event["type"] == "typing") {
        setState(() {
          typingUser = event["sender_id"];
        });
      } else if (event["type"] == "group:new_message") {
        setState(() {
          messages.add(event);
        });
      }
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await api.getMessages(widget.chatId);
    setState(() {
      messages = data;
    });
  }

  Future<void> _sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;
    await api.sendMessage(widget.chatId, widget.userId, content,
        receiverId: widget.receiverId);
    ws.sendUserMessage(widget.receiverId, content);
    messageController.clear();
    _loadMessages();
  }

  @override
  void dispose() {
    ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("J_ME Chat")),
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
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration:
                      const InputDecoration(hintText: "Type message..."),
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}
