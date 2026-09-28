import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/item.dart';
import 'auth_service.dart';

class ItemService {
    static Future<List<Item>> getRecentItems() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/items/recent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Item.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Item>> getNearbyItems(double lat, double lon, double radius) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/items/nearby?latitude=$lat&longitude=$lon&radius=$radius'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true', // added to prevent ngrok html pages
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Item.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Item>> getMyItems() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/user/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Item.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> resolveItem(int itemId, [int? finderId]) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/items/$itemId/resolve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: finderId != null ? {'finder_id': finderId.toString()} : {},
      ).timeout(Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> storeItem({
    required String name,
    required String description,
    required String status,
    required int bountyPoints,
    required double lat,
    required double lon,
    String? photoPath,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return 'Not authenticated';

      var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}/items'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['status'] = status;
      request.fields['bounty_points'] = bountyPoints.toString();
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = lon.toString();

      if (photoPath != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
      }

      var streamedResponse = await request.send().timeout(Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return null;
      } else {
        String err = response.body;
        return err.length > 200 ? err.substring(0, 200) : err;
      }
    } catch (e) {
      return 'Koneksi gagal. Periksa jaringan Anda.';
    }
  }

  static Future<bool> reportItem(int itemId, String reason, {String? evidencePath}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}/items/$itemId/report'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });
      request.fields['reason'] = reason;

      if (evidencePath != null) {
        request.files.add(await http.MultipartFile.fromPath('evidence', evidencePath));
      }

      var streamedResponse = await request.send().timeout(Duration(seconds: 30));
      return streamedResponse.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

