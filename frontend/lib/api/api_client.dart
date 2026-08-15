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
    final headers = {"Content-Type": "application/json"};
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

  Future<bool> uploadMedia(int chatId, int senderId, File file, String fileType) async {
    await loadToken();
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/media/upload"),
    );
    request.headers.addAll(_headers(auth: true));
    request.fields["message_id"] = chatId.toString();
    request.fields["file_type"] = fileType;
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    var response = await request.send();
    return response.statusCode == 200;
  }

  // 🟢 Root check
  Future<String> checkServer() async {
    final res = await http.get(Uri.parse("$baseUrl/"));
    return res.body;
  }

  // 👤 Create user
  Future<Map<String, dynamic>> createUser(
      String username, String email, String password,
      {String? phone, String? avatar}) async {
    final body = jsonEncode({
      "username": username,
      "email": email,
      "phone": phone,
      "password": password,
      "avatar": avatar
    });
    final res = await http.post(Uri.parse("$baseUrl/users/"),
        headers: _headers(), body: body);
    return jsonDecode(res.body);
  }

  // 🔐 Login
  Future<bool> login(String email, String password) async {
    final body = jsonEncode({"email": email, "password": password});
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

  // 💬 Send message
  Future<Map<String, dynamic>> sendMessage(
      int chatId, int senderId, String content) async {
    final body =
        jsonEncode({"chat_id": chatId, "sender_id": senderId, "content": content});
    final res = await http.post(Uri.parse("$baseUrl/messages/"),
        headers: _headers(auth: true), body: body);
    return jsonDecode(res.body);
  }

  // 📥 Get messages
  Future<List<dynamic>> getMessages(int chatId) async {
    final res = await http.get(Uri.parse("$baseUrl/messages/$chatId"),
        headers: _headers(auth: true));
    return jsonDecode(res.body);
  }

  // 👥 Create group
  Future<Map<String, dynamic>> createGroup(String name, int adminId) async {
    final body = jsonEncode({"name": name, "admin_id": adminId});
    final res = await http.post(Uri.parse("$baseUrl/groups/"),
        headers: _headers(auth: true), body: body);
    return jsonDecode(res.body);
  }

  // 📎 Upload media
  // 🔒 Set privacy
  Future<Map<String, dynamic>> setPrivacy(
      int userId, String setting, String value) async {
    final body = jsonEncode({"user_id": userId, "setting": setting, "value": value});
    final res = await http.post(Uri.parse("$baseUrl/privacy/"),
        headers: _headers(auth: true), body: body);
    return jsonDecode(res.body);
  }

  // 🔑 Create secret chat
  Future<Map<String, dynamic>> createSecretChat(
      int user1Id, int user2Id, String encryptionKey) async {
    final body = jsonEncode(
        {"user1_id": user1Id, "user2_id": user2Id, "encryption_key": encryptionKey});
    final res = await http.post(Uri.parse("$baseUrl/secret_chat/"),
        headers: _headers(auth: true), body: body);
    return jsonDecode(res.body);
  }

  Future<bool> setPrivacy(bool lastSeen, bool profilePhoto, bool readReceipts) async {
  await loadToken();
  final body = jsonEncode({
    "last_seen_visible": lastSeen,
    "profile_photo_visible": profilePhoto,
    "read_receipts_enabled": readReceipts,
  });
  final res = await http.post(Uri.parse("$baseUrl/privacy/set"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
 }
 
Future<List<dynamic>> getSecretMessages(int chatId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/secret_chat/$chatId"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}

Future<bool> setSettings(bool notifications, bool darkTheme, String username) async {
  await loadToken();
  final body = jsonEncode({
    "notifications_enabled": notifications,
    "dark_theme": darkTheme,
    "username": username,
  });
  final res = await http.post(Uri.parse("$baseUrl/settings/update"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}

Future<bool> setAppearance(String font, String bubbleStyle, String wallpaper) async {
  await loadToken();
  final body = jsonEncode({
    "font": font,
    "bubble_style": bubbleStyle,
    "wallpaper": wallpaper,
  });
  final res = await http.post(Uri.parse("$baseUrl/appearance/update"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<List<dynamic>> getStatuses() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/status"), headers: _headers(auth: true));
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
Future<bool> backupChats() async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/chat/backup"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
}

Future<bool> restoreChats() async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/chat/restore"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
}

Future<bool> setAutoBackup(bool enabled) async {
  await loadToken();
  final body = jsonEncode({"auto_backup": enabled});
  final res = await http.post(Uri.parse("$baseUrl/chat/auto_backup"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> exportChat(int chatId, String format, bool includeMedia) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "format": format,
    "include_media": includeMedia,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/export"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<Map<String, dynamic>> getChatInfo(int chatId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/chat/$chatId/info"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}

Future<bool> setMute(int chatId, bool muted) async {
  await loadToken();
  final body = jsonEncode({"muted": muted});
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/mute"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> setChatSecurity(int chatId, bool pinLock, bool fingerprint, bool twoFactor) async {
  await loadToken();
  final body = jsonEncode({
    "pin_lock": pinLock,
    "fingerprint_unlock": fingerprint,
    "two_factor_auth": twoFactor,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/security"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
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

Future<bool> revokeAllDevices() async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/account/revoke_devices"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
}
Future<List<dynamic>> getLoginHistory() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/account/login_history"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}
Future<bool> setPrivacySettings(
    String profile, String lastSeen, String status, bool receipts) async {
  await loadToken();
  final body = jsonEncode({
    "profile_visibility": profile,
    "last_seen_visibility": lastSeen,
    "status_visibility": status,
    "read_receipts": receipts,
  });
  final res = await http.post(Uri.parse("$baseUrl/privacy/update"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<Map<String, dynamic>> getAdvancedPrivacy() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/privacy/advanced"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}

Future<bool> setAdvancedPrivacy(bool forwarding, bool screenshots, bool secretChats) async {
  await loadToken();
  final body = jsonEncode({
    "forwarding": forwarding,
    "screenshots": screenshots,
    "secret_chats": secretChats,
  });
  final res = await http.post(Uri.parse("$baseUrl/privacy/advanced/update"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}

Future<bool> unblockUser(int userId) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/privacy/unblock/$userId"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
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
Future<bool> setSelfDestructTimer(int chatId, int seconds) async {
  await loadToken();
  final body = jsonEncode({"chat_id": chatId, "self_destruct": seconds});
  final res = await http.post(Uri.parse("$baseUrl/secret_chat/timer"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> sendViewOnce(int chatId, String filePath, String? caption) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "file_path": filePath,
    "caption": caption,
    "view_once": true
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/view_once"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 201;
}
Future<bool> setDisappearingMessages(int chatId, int duration) async {
  await loadToken();
  final body = jsonEncode({"chat_id": chatId, "duration": duration});
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/disappearing"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> editMessage(int chatId, int messageId, String newText) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "message_id": messageId,
    "new_text": newText,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/message/$messageId/edit"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> deleteMessageForMe(int chatId, int messageId) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/message/$messageId/delete_for_me"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
}

Future<bool> deleteMessageForEveryone(int chatId, int messageId) async {
  await loadToken();
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/message/$messageId/delete_for_everyone"),
      headers: _headers(auth: true));
  return res.statusCode == 200;
}
Future<bool> addReaction(int chatId, int messageId, String reaction) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "message_id": messageId,
    "reaction": reaction,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/message/$messageId/reaction"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}

Future<bool> removeReaction(int chatId, int messageId, String reaction) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "message_id": messageId,
    "reaction": reaction,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/message/$messageId/reaction/remove"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> sendThreadReply(int chatId, int parentId, String text) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "parent_id": parentId,
    "text": text,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/thread/reply"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 201;
}

Future<List<dynamic>> getThreadReplies(int chatId, int parentId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/chat/$chatId/thread/$parentId"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}
Future<List<dynamic>> getChats() async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/chats"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}

Future<bool> forwardMessage(int messageId, List<int> chatIds) async {
  await loadToken();
  final body = jsonEncode({"message_id": messageId, "chat_ids": chatIds});
  final res = await http.post(Uri.parse("$baseUrl/message/$messageId/forward"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 200;
}
Future<bool> sendReply(int chatId, int parentId, String text) async {
  await loadToken();
  final body = jsonEncode({
    "chat_id": chatId,
    "parent_id": parentId,
    "text": text,
  });
  final res = await http.post(Uri.parse("$baseUrl/chat/$chatId/reply"),
      headers: _headers(auth: true), body: body);
  return res.statusCode == 201;
}

Future<List<dynamic>> getReplies(int chatId, int parentId) async {
  await loadToken();
  final res = await http.get(Uri.parse("$baseUrl/chat/$chatId/replies/$parentId"),
      headers: _headers(auth: true));
  return jsonDecode(res.body);
}

}

