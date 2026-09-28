import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'auth_service.dart';
import 'chat_service.dart';
import '../constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  
    static Future<List<dynamic>> getHistory() async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  static Future<void> markRead(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return;
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/notifications/$id/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: initAndroid);
    await _plugin.initialize(settings: initSettings);

    // Request FCM permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        await AuthService.updateFcmToken(token);
      }
    }

    // Listen to token refresh
    messaging.onTokenRefresh.listen((newToken) {
      AuthService.updateFcmToken(newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _plugin.show(
          id: message.notification.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Chat Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  static void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _checkNewNotifications();
    });
  }

  static void stopPolling() {
    _timer?.cancel();
  }

  static Future<void> _checkNewNotifications() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        for (var notif in data) {
          if (notif['read_at'] == null) {
            _showPushNotification(notif['data']['message'] ?? 'Notifikasi Baru');
            await _markAsRead(notif['id']);
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }

  static Future<void> _showPushNotification(String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'lostandfound_channel',
      'Pencocokan Barang',
      channelDescription: 'Notifikasi saat ada barang yang cocok',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    await _plugin.show(
      id: DateTime.now().millisecond,
      title: 'Match Ditemukan!',
      body: body,
      notificationDetails: platformDetails,
    );
  }

  static Future<void> _markAsRead(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return;
    
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/notifications/$id/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}

