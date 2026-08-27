import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/ws_client.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int userId;
  final Map<String, dynamic> receiver; // expects { "id": int, "username": String, "avatarUrl": String? }

  const ChatScreen({
    super.key,
    required this.receiver,
    this.chatId = 1,
    this.userId = 1,
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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // Connect websocket for current user
    ws.connectUser(userId: widget.userId);

    // Listen websocket events
    ws.stream.listen((event) {
      final type = event["type"];
      if (type == "direct_message") {
        // Only add messages that belong to this chat or from this receiver
        final senderId = event["sender_id"];
        final receiverId = event["receiver_id"];
        if (senderId == widget.receiver["id"] || receiverId == widget.receiver["id"]) {
          setState(() => messages.add(event));
        }
      } else if (type == "typing") {
        final senderId = event["sender_id"];
        if (senderId == widget.receiver["id"]) {
          setState(() {
            typingUser = senderId;
          });
          // clear typing indicator after a short delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && typingUser == senderId) {
              setState(() => typingUser = null);
            }
          });
        }
      } else if (type == "group:new_message") {
        // ignore group messages unless you want to show them
      }
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => loading = true);
    try {
      // Expect api.getMessages to accept chatId and optionally filter by participant
      final data = await api.getMessages(widget.chatId);
      // Filter messages to/from the receiver if API returns global chat messages
      final filtered = data.where((m) {
        final sender = m["sender_id"];
        final receiver = m["receiver_id"];
        return sender == widget.receiver["id"] || receiver == widget.receiver["id"];
      }).toList();
      setState(() {
        messages = filtered;
      });
    } catch (e) {
      // handle error or show snackbar
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;
    // send via API
    await api.sendMessage(widget.chatId, widget.userId, content,
        receiverId: widget.receiver["id"]);
    // notify via websocket
    ws.sendUserMessage(widget.receiver["id"], content);
    messageController.clear();
    await _loadMessages();
  }

  @override
  void dispose() {
    ws.dispose();
    messageController.dispose();
    super.dispose();
  }

  Widget _buildMessageTile(dynamic msg) {
    final isMe = msg["sender_id"] == widget.userId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg["content"] ?? '',
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              msg["created_at"] ?? '',
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiver = widget.receiver;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: receiver["avatarUrl"] != null
                  ? NetworkImage(receiver["avatarUrl"])
                  : null,
              child: receiver["avatarUrl"] == null
                  ? Text((receiver["username"] ?? 'U').substring(0, 1).toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiver["username"] ?? 'Unknown',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // show newest at bottom: if messages are chronological, reverse index
                      final msg = messages[messages.length - 1 - index];
                      return _buildMessageTile(msg);
                    },
                  ),
          ),
          if (typingUser == widget.receiver["id"])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${receiver["username"]} is typing...',
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (text) {
                      // send typing event to websocket
                      ws.sendTyping(widget.receiver["id"]);
                    },
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
