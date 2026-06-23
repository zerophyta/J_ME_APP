import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/ws_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  ws.stream.listen((event) {
  if (event["type"] == "message:new") {
    setState(() {
      messages.add(event["data"]);
    });
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


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiClient api = ApiClient();
  final WsClient ws = WsClient();
  final messageController = TextEditingController();
  List<dynamic> messages = [];

    @override
      void initState() {
       super.initState();
        ws.connect(userId: 1); // current user id
        ws.stream.listen((event) {
         if (event["type"] == "message:new") {
         setState(() {
          messages.add(event["data"]);
        });
      }
    });
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await api.getMessages(1); // chat_id = 1
    setState(() {
      messages = data;
    });
  }

  Future<void> _sendMessage() async {
    await api.sendMessage(1, 1, messageController.text); // chat_id=1, sender_id=1
    ws.send({"type": "message:new", "data": {"content": messageController.text, "sender_id": 1}});                              
    messageController.clear();
    _loadMessages();
  }

  @override
  void initState() {
    super.initState();
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
              Expanded(child: TextField(controller: messageController, decoration: const InputDecoration(hintText: "Type message..."))),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}


