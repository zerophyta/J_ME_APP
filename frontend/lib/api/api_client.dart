import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiClient {
  final String baseUrl = "http://127.0.0.1:8000"; // Ubuntu backend IP

  // 🔑 Store JWT token after login
  String? token;

  // Helper: add headers
  Map<String, String> _headers({bool auth = false}) {
    final headers = {"Accept": "application/json"};
    if (auth && token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    token = authToken;
    await prefs.setString('auth_token', authToken);
  }

  
  // 🟢 Root check
  Future<String> checkServer() async {
    final res = await http.get(Uri.parse("$baseUrl/"));
    return res.body;
  }

 // ======================
// 1. Auth & User
// ======================
Future<Map<String, dynamic>> createUser(String username, String email, String password,
    {String? phone, String? avatar}) async {
  final body = jsonEncode({
    "username": username,
    "email": email,
    "phone": phone,
    "password": password,
    "avatar": avatar
  });
  final res = await http.post(Uri.parse("$baseUrl/auth/register"),
      headers: _headers(), body: body);
  return jsonDecode(res.body);
  }

Future<bool> login(String email, String password) async {
  final body = jsonEncode({"identifier": email, "password": password});
  final res = await http.post(Uri.parse("$baseUrl/auth/login"),
      headers: _headers(), body: body);
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final authToken = data["token"];
    if (authToken != null) {
      await saveToken(authToken);
      return true;
    }
  }
  return false;
  }

Future<Map<String, dynamic>> getUser(int userId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/users/$userId"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> values) async {
  await loadToken();
  final res = await http.put(Uri.parse("$baseUrl/users/$userId"),
      headers: _headers(auth: true), body: jsonEncode(values));
  return jsonDecode(res.body);
  }

// ======================
// 7. Chats
// ======================
Future<List<dynamic>> getChats() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/chats"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<Map<String, dynamic>> startChat(String identifier, int currentUserId) async {
  await loadToken();
  final uri = Uri.parse("$baseUrl/chats/start").replace(queryParameters: {
    "identifier": identifier,
    "current_user_id": currentUserId.toString(),
  });
  final res = await http.post(uri, headers: _headers(auth: true));
  return jsonDecode(res.body);
  }


 // ======================
// 2. Messages & Attachments
// ======================
Future<Map<String, dynamic>> sendMessage(int chatId, int senderId, String content,
    {int? receiverId, int? groupId}) async {
  final body = jsonEncode({
    if (groupId == null) "chat_id": chatId,
    if (groupId != null) "group_id": groupId,
    "sender_id": senderId,
    "receiver_id": receiverId,
    "content": content,
  });
  final res = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages"),
      headers: _headers(auth: true), body: body);
  return jsonDecode(res.body);
  }

Future<List<dynamic>> getMessages(int chatId, {int? groupId}) async {
  final query = groupId == null ? "chat_id=$chatId" : "group_id=$groupId";
  final res = await http.get(Uri.parse("$baseUrl/messages/?$query"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<List<dynamic>> getSecretMessages(int secretChatId) async {
  await loadToken();
  final res = await http.get(
      Uri.parse("$baseUrl/messages/?secret_chat_id=$secretChatId"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

// Attachments (examples)
Future<bool> uploadFile(int chatId, int senderId, File file) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/file/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  final response = await request.send();
  return response.statusCode == 200;
  }


// ======================
// 6. Message Management
// ======================
Future<bool> editMessage(int chatId, int messageId, String newText) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "message_id": messageId,
    "new_text": newText,
  });
  final res = await http.post(
      Uri.parse("$baseUrl/chat/$chatId/message/$messageId/edit"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
  }

Future<bool> deleteMessageForMe(int chatId, int messageId) async {
  await loadToken();
  final res = await http.post(
      Uri.parse("$baseUrl/chat/$chatId/message/$messageId/delete_for_me"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }


// Similar implementations for uploadImage, uploadVideo, uploadAudio, etc.
// ======================
// 3. Groups & Broadcast
// ======================
Future<Map<String, dynamic>> createGroup(String name, int adminId) async {
  final body = jsonEncode({"name": name, "admin_id": adminId});
  final res = await http.post(Uri.parse("$baseUrl/groups/"),
      headers: _headers(auth: true), body: body);
  return jsonDecode(res.body);
  }

Future<List<dynamic>> getGroups() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/groups/"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<Map<String, dynamic>> sendBroadcast(int senderId, List<int> recipientIds, String content) async {
  await loadToken();
  final body = jsonEncode({
    "sender_id": senderId,
    "recipient_ids": recipientIds,
    "content": content,
  });
  final res = await http.post(Uri.parse("$baseUrl/broadcast"),
      headers: _headers(auth: true), body: body);
  return jsonDecode(res.body);
  }

// ======================
// 4. Privacy & Settings
// ======================
Future<Map<String, dynamic>> settings(int userId, String setting, String value) async {
  final body = jsonEncode({"user_id": userId, "setting": setting, "value": value});
  final res = await http.post(Uri.parse("$baseUrl/privacy/"),
      headers: _headers(auth: true), body: body);
  return jsonDecode(res.body);
  }

Future<bool> setPrivacy(bool lastSeenVisible, bool profilePhotoVisible, bool readReceiptsEnabled,
    {int userId = 1}) async {
  await loadToken();
  final settings = {
    "last_seen": lastSeenVisible,
    "profile_photo": profilePhotoVisible,
    "read_receipts": readReceiptsEnabled,
  };
  for (final entry in settings.entries) {
    final response = await http.post(
      Uri.parse("$baseUrl/privacy/"),
      headers: _headers(auth: true),
      body: jsonEncode({
        "user_id": userId,
        "setting": entry.key,
        "value": entry.value.toString(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }
  }
  return true;
  }

Future<Map<String, dynamic>> getAdvancedPrivacy() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/privacy/advanced"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<bool> setAdvancedPrivacy(Map<String, dynamic> settings) async {  
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/privacy/advanced"),
      headers: _headers(auth: true), body: jsonEncode(settings));
  return res.statusCode == 200;
  }

Future<bool> unblockUser(int id) async {  
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/privacy/unblock/$id"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<bool> blockUser(int id) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/privacy/block/$id"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  } 

Future<bool> setBlockedUsers(List<int> blockedUserIds) async {
  await loadToken();
  final body = jsonEncode({"blocked_user_ids": blockedUserIds});
  final res = await http.post(Uri.parse("$baseUrl/privacy/set_blocked_users"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
  } 

Future<List<int>> getBlockedUsers() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/privacy/blocked_users"),
      headers: _headers(auth: true));
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return List<int>.from(data['blocked_user_ids']);
  } else {
    throw Exception('Failed to fetch blocked users');
  }
  }

Future<bool> setsettings(int userId, String setting, String value) async {
  await loadToken();
  final body = jsonEncode({"user_id": userId, "setting": setting, "value": value});
  final res = await http.post(Uri.parse("$baseUrl/privacy/"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
  }

Future<Map<String, dynamic>> getsettings(int userId, String setting) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/privacy/$userId/$setting"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<bool> setNotificationSettings(int userId, Map<String, dynamic> settings) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/notifications/settings"),
      headers: _headers(auth: true), body: jsonEncode({"user_id": userId, "settings": settings}));
  return res.statusCode == 200;
  }
    


// ======================
// 5. Secret Chats
// ======================
Future<Map<String, dynamic>> createSecretChat(int user1Id, int user2Id, String encryptionKey) async {
  final body = jsonEncode({
    "user1_id": user1Id,
    "user2_id": user2Id,
    "encryption_key": encryptionKey
  });
  final res = await http.post(Uri.parse("$baseUrl/secret_chat/"),
      headers: _headers(auth: true), body: body);
  return jsonDecode(res.body);
  }

Future<bool> sendSecretMessage(int chatId, int userId, String content, [int destructSeconds = 0]) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "user_id": userId,
    "content": content,
    "self_destruct": destructSeconds,
  });
  final res = await http.post(Uri.parse("$baseUrl/secret_chat/send"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 201;
  }

// ======================
// 8. Statuses
// ======================
Future<List<dynamic>> getStatuses() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/status"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<bool> uploadStatus(String content) async {
  await loadToken();
  final body = jsonEncode({"content": content});
  final res = await http.post(Uri.parse("$baseUrl/status/upload"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 201;
  }

Future<List<dynamic>> getStatusViewers(int statusId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/status/$statusId/viewers"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<List<dynamic>> getArchivedStatuses() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/status/archive"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

// ======================
// 9. Storage
// ======================
Future<Map<String, dynamic>> getStorageUsage() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/storage/usage"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<bool> clearCache() async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/storage/clear"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<bool> setAutoDownload(bool enabled) async {
  await loadToken();
  final body = jsonEncode({"auto_download": enabled});
  final res = await http.post(Uri.parse("$baseUrl/storage/auto_download"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
  }

// ======================
// 10. Devices & Security
// ======================
Future<List<dynamic>> getActiveDevices() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/devices/active"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<bool> revokeDevice(int deviceId) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/devices/$deviceId/revoke"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<bool> revokeAllDevices() async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/account/revoke_devices"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<Map<String, dynamic>> getAccountSecurity() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/account/security"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<bool> setTwoFactor(bool enabled) async {
  await loadToken();
  final body = jsonEncode({"two_factor": enabled});
  final res = await http.post(Uri.parse("$baseUrl/account/two_factor"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
  }

Future<List<dynamic>> getLoginHistory() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/account/login_history"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

// ======================
// 11. Calls
// ======================
Future<Map<String, dynamic>> startCall(int callerId, int calleeId, String callType) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/calls/start"),
      headers: _headers(auth: true),
      body: jsonEncode({
        "caller_id": callerId,
        "callee_id": calleeId,
        "call_type": callType
      }));
  return jsonDecode(res.body);
  }

Future<List<dynamic>> getCallHistory(int userId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/calls/history/$userId"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<Map<String, dynamic>> endCall(int callId) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/calls/$callId/end"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

Future<Map<String, dynamic>> startGroupCall(int callerId, int chatId, String callType) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/group_calls/start"),
      headers: _headers(auth: true),
      body: jsonEncode({
        "caller_id": callerId,
        "chat_id": chatId,
        "call_type": callType
      }));
  return jsonDecode(res.body);
  }

Future<Map<String, dynamic>> joinGroupCall(int callId, int userId) async {
  await loadToken();
  final uri = Uri.parse("$baseUrl/group_calls/$callId/join")
      .replace(queryParameters: {"user_id": userId.toString()});
  final res = await http.post(uri, headers: _headers(auth: true));
  return jsonDecode(res.body);
  }

// ======================
// Upload Attachments
// ======================

Future<bool> uploadImage(int chatId, int senderId, File image) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/image/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('image', image.path));
  final response = await request.send();
  return response.statusCode == 200;
  }

Future<bool> uploadVideo(int chatId, int senderId, File video) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/video/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('video', video.path));
  final response = await request.send();
  return response.statusCode == 200;
  }

Future<bool> uploadAudio(int chatId, int senderId, File audio) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/audio/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('audio', audio.path));
  final response = await request.send();
  return response.statusCode == 200;
  }

Future<bool> uploadDocument(int chatId, int senderId, File document) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/document/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('document', document.path));
  final response = await request.send();
  return response.statusCode == 200;
  }

Future<bool> uploadSticker(int chatId, int senderId, File sticker) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/sticker/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('sticker', sticker.path));
  final response = await request.send();
  return response.statusCode == 200;
  }

Future<bool> uploadVoiceNote(int chatId, int senderId, File voiceNote) async {
  await loadToken();
  final request = http.MultipartRequest(
      'POST', Uri.parse("$baseUrl/user/{user_id}/messages/voice_note/"));
  request.headers.addAll(_headers(auth: true));
  request.fields['chat_id'] = chatId.toString();
  request.fields['sender_id'] = senderId.toString();
  request.files.add(await http.MultipartFile.fromPath('voice_note', voiceNote.path));
  final response = await request.send();
  return response.statusCode == 200;
  }

// Metadata-based uploads
Future<bool> uploadLocation(int chatId, int senderId, double latitude, double longitude) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "latitude": latitude,
    "longitude": longitude,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/location/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadContact(int chatId, int senderId, String contactName, String contactNumber) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "contact_name": contactName,
    "contact_number": contactNumber,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/contact/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadPoll(int chatId, int senderId, String question, List<String> options) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "question": question,
    "options": options,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/poll/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadEvent(int chatId, int senderId, String eventName, String eventDate) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "event_name": eventName,
    "event_date": eventDate,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/event/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadTask(int chatId, int senderId, String taskName, String dueDate) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "task_name": taskName,
    "due_date": dueDate,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/task/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadAnnouncement(int chatId, int senderId, String announcement) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "announcement": announcement,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/announcement/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadReminder(int chatId, int senderId, String reminderText, String reminderTime) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "reminder_text": reminderText,
    "reminder_time": reminderTime,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/reminder/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadReaction(int chatId, int senderId, int messageId, String reaction) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "message_id": messageId,
    "reaction": reaction,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/reaction/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<bool> uploadStickerPack(int chatId, int senderId, String packName, List<String> stickers) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "pack_name": packName,
    "stickers": stickers,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/sticker_pack/"),
      headers: _headers(auth: true), body: body);
  return response.statusCode == 200;
  }

Future<void> sendAttachment(int chatId, int senderId, File file, {required int receiverId}) async {
  final attachments = [
    {
      "receiver_id": receiverId,
      "file_path": file.path,
      "type": "file",
    }
  ];
  await sendAttachments(chatId, senderId, attachments);
  }

Future<void> sendAttachments(int chatId, int senderId, List<Map<String, dynamic>> attachments) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "sender_id": senderId,
    "attachments": attachments,
  });
  final response = await http.post(Uri.parse("$baseUrl/user/{user_id}/messages/attachments/"),
      headers: _headers(auth: true), body: body);
  if (response.statusCode != 200) {
    throw Exception('Failed to send attachments');
   }
  }

Future<bool> forwardMessage(int messageId, List<int> chatIds) async { 
  await loadToken();
  final body = jsonEncode({
    "message_id": messageId,
    "chat_ids": chatIds,
  });
  final res = await http.post(Uri.parse("$baseUrl/messages/forward"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
  }

Future<bool> markMessageAsRead(int messageId) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/messages/$messageId/read"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<bool> deleteMessageForEveryone(int chatId, int messageId) async {
  await loadToken();
  final res = await http.post(
      Uri.parse("$baseUrl/chat/$chatId/message/$messageId/delete_for_everyone"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<bool> leaveGroupCall(int callId, int userId) async {
  await loadToken();
  final uri = Uri.parse("$baseUrl/group_calls/$callId/leave")
      .replace(queryParameters: {"user_id": userId.toString()});
  final res = await http.post(uri, headers: _headers(auth: true));
  return res.statusCode == 200;
  }

Future<bool> endGroupCall(int callId, int userId) async {
  await loadToken();
  final uri = Uri.parse("$baseUrl/group_calls/$callId/end")
      .replace(queryParameters: {"user_id": userId.toString()});
  final res = await http.post(uri, headers: _headers(auth: true));
  return res.statusCode == 200;
  }
}
