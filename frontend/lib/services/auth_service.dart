import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveRadius(double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('search_radius', radius);
  }

  static Future<double> getRadius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('search_radius') ?? 10.0;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/login'),
        headers: {'ngrok-skip-browser-warning': 'true'},
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['access_token']);
        return {'success': true};
      } else {
        try {
          final data = json.decode(response.body);
          String msg = data['message'] ?? 'Login failed';
          if (data['errors'] != null) {
            msg = (data['errors'] as Map).values.first[0];
          }
          return {'success': false, 'message': msg};
        } catch (e) {
          return {'success': false, 'message': 'Login failed: Invalid credentials'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa jaringan Anda.'};
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/register'),
        headers: {'ngrok-skip-browser-warning': 'true'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone_number': phone,
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveToken(data['access_token']);
        return {'success': true};
      } else {
        try {
          final data = json.decode(response.body);
          String msg = data['message'] ?? 'Registration failed';
          if (data['errors'] != null) {
            msg = (data['errors'] as Map).values.first[0];
          }
          return {'success': false, 'message': msg};
        } catch (e) {
          return {'success': false, 'message': 'Registration failed'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa jaringan Anda.'};
    }
  }

  static Future<User?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateFcmToken(String fcmToken) async {
    try {
      final token = await getToken();
      if (token == null) return;
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/fcm-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {'fcm_token': fcmToken},
      );
    } catch (e) {
      // ignore
    }
  }

  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConstants.baseUrl}/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ).timeout(Duration(seconds: 5));
      }
    } catch (e) {
      // ignore
    } finally {
      await removeToken();
    }
  }

  static Future<Map<String, dynamic>> updateProfile(String name, String? phone, String? password, {String? photoPath}) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}/user'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['_method'] = 'PUT';

      request.fields['name'] = name;
      if (phone != null) request.fields['phone_number'] = phone;
      if (password != null && password.isNotEmpty) request.fields['password'] = password;

      if (photoPath != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
      }

      final streamedResponse = await request.send().timeout(Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        try {
          final data = json.decode(response.body);
          String msg = data['message'] ?? 'Update failed';
          if (data['errors'] != null) {
            msg = (data['errors'] as Map).values.first[0];
          }
          return {'success': false, 'message': msg};
        } catch (e) {
          return {'success': false, 'message': 'Update failed'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa jaringan Anda.'};
    }
  }
}
