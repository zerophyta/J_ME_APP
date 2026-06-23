import 'package:flutter/material.dart';
import '../api/api_client.dart';

class ForwardMessageScreen extends StatefulWidget {
  final int messageId;
  const ForwardMessageScreen({super.key, required this.messageId});

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> chats = [];
  List<int> selectedChats = [];
  String message = "";

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final data = await api.getChats();
    setState(() => chats = data);
  }

  Future<void> _forward() async {
    bool success = await api.forwardMessage(widget.messageId, selectedChats);
    setState(() {
      message = success ? "Message forwarded ✅" : "Forward failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forward Message")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (_, i) {
                final chat = chats[i];
                final selected = selectedChats.contains(chat["id"]);
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(chat["avatar"])),
                  title: Text(chat["name"]),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedChats.add(chat["id"]);
                        } else {
                          selectedChats.remove(chat["id"]);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: _forward, child: const Text("Forward")),
          const SizedBox(height: 10),
          Text(message),
        ],
      ),
    );
  }
}
