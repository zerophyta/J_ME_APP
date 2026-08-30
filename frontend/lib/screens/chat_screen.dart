import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../api/api_client.dart';
import '../api/ws_client.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int userId;
  final Map<String, dynamic> receiver;

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
    ws.connectUser(userId: widget.userId);

    ws.stream.listen((event) {
      final type = event["type"];
      if (type == "direct_message") {
        final senderId = event["sender_id"];
        final receiverId = event["receiver_id"];
        if (senderId == widget.receiver["id"] ||
            receiverId == widget.receiver["id"]) {
          setState(() => messages.add(event));
        }
      } else if (type == "typing") {
        final senderId = event["sender_id"];
        if (senderId == widget.receiver["id"]) {
          setState(() => typingUser = senderId);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && typingUser == senderId) {
              setState(() => typingUser = null);
            }
          });
        }
      }
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => loading = true);
    try {
      final data = await api.getMessages(widget.chatId);
      final filtered = data.where((m) {
        final sender = m["sender_id"];
        final receiver = m["receiver_id"];
        return sender == widget.receiver["id"] ||
            receiver == widget.receiver["id"];
      }).toList();
      setState(() => messages = filtered);
    } catch (e) {
      // handle error
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    await api.sendMessage(
      widget.chatId,
      widget.userId,
      content,
      receiverId: widget.receiver["id"],
    );

    ws.sendUserMessage(widget.receiver["id"], content);
    messageController.clear();
    await _loadMessages();
  }

  Future<void> _sendAttachment(File file) async {
    await api.sendAttachment(
      widget.chatId,
      widget.userId,
      file,
      receiverId: widget.receiver["id"],
    );
    ws.sendUserAttachment(widget.receiver["id"], file.path);
    await _loadMessages();
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
              msg["created_at"]?.toString() ?? '',
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
  void dispose() {
    ws.dispose();
    messageController.dispose();
    super.dispose();
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
                  ? Text((receiver["username"] ?? 'U')[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Text(receiver["username"] ?? 'Unknown'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ws.startVoiceCall(
                  chatId: widget.chatId, receiverId: receiver["id"]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ws.startVideoCall(
                  chatId: widget.chatId, receiverId: receiver["id"]);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAttachmentOptions,
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          messageController.text += emoji.emoji;
                        },
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (text) {
                      ws.sendTyping(widget.chatId, widget.receiver["id"]);
                    },
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showAttachmentOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Image"),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null) {
                final file = File(result.files.first.path!);
                await api.uploadImage(widget.chatId, widget.userId, file);
                ws.sendUserAttachment(widget.receiver["id"], file.path);
                await _loadMessages();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text("Video"),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(type: FileType.video);
              if (result != null) {
                final file = File(result.files.first.path!);
                await api.uploadVideo(widget.chatId, widget.userId, file);
                ws.sendUserAttachment(widget.receiver["id"], file.path);
                await _loadMessages();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack),
            title: const Text("Audio"),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(type: FileType.audio);
              if (result != null) {
                final file = File(result.files.first.path!);
                await api.uploadAudio(widget.chatId, widget.userId, file);
                ws.sendUserAttachment(widget.receiver["id"], file.path);
                await _loadMessages();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text("Document"),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(type: FileType.any);
              if (result != null) {
                final file = File(result.files.first.path!);
                await api.uploadDocument(widget.chatId, widget.userId, file);
                ws.sendUserAttachment(widget.receiver["id"], file.path);
                await _loadMessages();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.poll),
            title: const Text("Poll"),
            onTap: () async {
              Navigator.pop(context);
              await api.uploadPoll(widget.chatId, widget.userId,
                  "Which feature do you like?", ["Chat", "Calls", "Status"]);
              ws.sendUserAttachment(widget.receiver["id"], "Poll created");
              await _loadMessages();
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Location"),
            onTap: () async {
              Navigator.pop(context);
              await api.uploadLocation(widget.chatId, widget.userId, -6.8, 39.2);
              ws.sendUserAttachment(widget.receiver["id"], "Location shared");
              await _loadMessages();
            },
          ),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text("Contact"),
            onTap: () async {
              Navigator.pop(context);
              await api.uploadContact(widget.chatId, widget.userId,
                  "John Doe", "+255700000000");
              ws.sendUserAttachment(widget.receiver["id"], "Contact shared");
              await _loadMessages();
            },
          ),
        ],
      );
    },
  );
}
