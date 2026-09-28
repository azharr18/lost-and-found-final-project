import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/chat.dart';
import 'auth_service.dart';

class ChatService {
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Chat>> getChats(int otherUserId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/chats/$otherUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Chat.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> sendMessage(int receiverId, String message) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'receiver_id': receiverId.toString(),
          'message': message,
        },
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<void> markRead(int otherUserId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      await http.post(
        Uri.parse('${AppConstants.baseUrl}/chats/$otherUserId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(Duration(seconds: 5));
    } catch (e) {
      // ignore
    }
  }
}
