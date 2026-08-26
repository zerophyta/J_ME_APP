import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/ws_client.dart';
import 'group_call_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final int groupId;
  final int userId;
  final List<int> members;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.userId,
    required this.members,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final ApiClient api = ApiClient();
  final WsClient ws = WsClient();
  final messageController = TextEditingController();

  List<dynamic> messages = [];
  int? typingUser;

  @override
  void initState() {
    super.initState();
    ws.connectChat(chatId: widget.groupId);

    // Listen to WebSocket events
    ws.stream.listen((event) {
      if (event["chat_id"] == widget.groupId) {
        setState(() {
          messages.add(event);
        });
      } else if (event["type"] == "typing") {
        setState(() {
          typingUser = event["sender_id"];
        });
      }
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await api.getMessages(widget.groupId, groupId: widget.groupId);
    setState(() {
      messages = data;
    });
  }

  Future<void> _sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;
    await api.sendMessage(widget.groupId, widget.userId, content,
        groupId: widget.groupId);
    ws.sendGroupMessage(widget.userId, content);
    messageController.clear();
  }

  void _sendTyping() {
    ws.sendTyping(widget.groupId, widget.userId);
  }

  @override
  void dispose() {
    ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Chat"),
        actions: [
          IconButton(
            tooltip: 'Start group voice call',
            icon: const Icon(Icons.phone),
            onPressed: () => _openGroupCall('group_voice'),
          ),
          IconButton(
            tooltip: 'Start group video call',
            icon: const Icon(Icons.videocam),
            onPressed: () => _openGroupCall('group_video'),
          ),
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
                );
              },
            ),
          ),
          if (typingUser != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("User $typingUser is typing..."),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration:
                      const InputDecoration(hintText: "Type message..."),
                  onChanged: (_) => _sendTyping(),
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }

  void _openGroupCall(String callType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupCallScreen(
          groupId: widget.groupId,
          userId: widget.userId,
          initialCallType: callType,
        ),
      ),
    );
  }
}
