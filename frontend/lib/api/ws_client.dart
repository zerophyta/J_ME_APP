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
      Uri.parse("ws://127.0.0.1:8000/ws/call/$userId"),
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

  // Messaging
  void sendUserMessage(int receiverId, String content) {
    send({"receiver_id": receiverId, "content": content});
  }

  void sendGroupMessage(int senderId, String content) {
    send({"sender_id": senderId, "content": content});
  }

  void sendTyping(int chatId, int senderId) {
    send({"type": "typing", "chat_id": chatId, "sender_id": senderId});
  }

  // Call signaling
  void sendCallSignal(int senderId, int receiverId, String signalData) {
    send({"type": "call_signal", "sender_id": senderId, "receiver_id": receiverId, "signal_data": signalData});
  }

  void sendCallEnd(int senderId, int receiverId) {
    send({"type": "call_end", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallAccept(int senderId, int receiverId) {
    send({"type": "call_accept", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallReject(int senderId, int receiverId) {
    send({"type": "call_reject", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallBusy(int senderId, int receiverId) {
    send({"type": "call_busy", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallMissed(int senderId, int receiverId) {
    send({"type": "call_missed", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallTimeout(int senderId, int receiverId) {
    send({"type": "call_timeout", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallCancel(int senderId, int receiverId) {
    send({"type": "call_cancel", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallEndAll(int senderId) {
    send({"type": "call_end_all", "sender_id": senderId});
  }

  void sendCallEndGroup(int senderId, int groupId) {
    send({"type": "call_end_group", "sender_id": senderId, "group_id": groupId});
  }

  void sendCallEndPrivate(int senderId, int receiverId) {
    send({"type": "call_end_private", "sender_id": senderId, "receiver_id": receiverId});
  }

  void startVoiceCall(int senderId, int receiverId) {
    send({"type": "start_voice_call", "sender_id": senderId, "receiver_id": receiverId});
  }

  void startVideoCall(int senderId, int receiverId) {
    send({"type": "start_video_call", "sender_id": senderId, "receiver_id": receiverId});
  }

  void sendCallEndBroadcast(int senderId, int broadcastId) {
    send({"type": "call_end_broadcast", "sender_id": senderId, "broadcast_id": broadcastId});
  }

  void sendUserAttachment(int receiverId, String filePath) {
  send({
    "type": "user_attachment","receiver_id": receiverId,"file_path": filePath});
  }

}

