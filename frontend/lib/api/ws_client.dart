import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  WebSocketChannel? _channel;

  void connectUser({required int userId}) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:8000/ws/user/$userId"),
    );
  }

  void connectChat({required int chatId}) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:8000/ws/chat/$chatId"),
    );
  }

  void connectCall({required int userId}) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:8000/ws/ws/call/$userId"),
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

  void sendUserMessage(int receiverId, String content) {
    send({"receiver_id": receiverId, "content": content});
  }

  void sendGroupMessage(int senderId, String content) {
    send({"sender_id": senderId, "content": content});
  }

  void sendTyping(int chatId, int senderId) {
    send({"type": "typing", "chat_id": chatId, "sender_id": senderId});
  }
}
