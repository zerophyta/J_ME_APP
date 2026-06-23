import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  WebSocketChannel? _channel;

  void connect({required int userId}) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:8000/ws/connect?user_id=$userId"),
    );
  }

  Stream<dynamic> get stream =>
      _channel!.stream.map((event) => jsonDecode(event));

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel?.sink.close();
  }

  void sendTyping(int chatId, int senderId) {
  send({"type": "typing", "chat_id": chatId, "sender_id": senderId});
}

  void sendGroupMessage(int chatId, int senderId, String content, List<int> members) {
  send({
    "type": "group:new_message",
    "chat_id": chatId,
    "sender_id": senderId,
    "content": content,
    "group_members": members
  });
  
    }
  }



