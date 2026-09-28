import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../constants.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final notifs = await NotificationService.getHistory();
    if (!mounted) return;
    setState(() {
      _notifications = notifs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgLightBlue,
      appBar: AppBar(
        title: Text('Riwayat Notifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _notifications.isEmpty 
          ? Center(child: Text('Belum ada notifikasi.'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final bool isRead = notif['read_at'] != null;
                final data = notif['data'] ?? {};
                
                return InkWell(
                  onTap: () {
                    if (!isRead) {
                      NotificationService.markRead(notif['id']);
                      setState(() {
                        notif['read_at'] = DateTime.now().toIso8601String();
                      });
                    }
                    // Could navigate to item detail, but we might not have the full Item object easily available here.
                    // Or we could fetch it by ID. But this satisfies the history requirement.
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : Colors.blue.withOpacity(0.05),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isRead ? Colors.grey[200] : AppConstants.primaryBlue.withOpacity(0.2),
                          child: Icon(
                            isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: isRead ? Colors.grey : AppConstants.primaryBlue,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['message'] ?? 'Notifikasi baru',
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  color: Colors.black87
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ketuk untuk menandai sudah dibaca',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppConstants.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}