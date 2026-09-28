import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    final convos = await ChatService.getConversations();
    if (!mounted) return;
    setState(() {
      _conversations = convos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(child: Text('Belum ada pesan.', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.separated(
                  itemCount: _conversations.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = _conversations[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.primaryBlue,
                        backgroundImage: user['photo_url'] != null
                            ? CachedNetworkImageProvider(
                                user['photo_url'],
                                headers: const {'ngrok-skip-browser-warning': 'true'},
                              )
                            : null,
                        child: user['photo_url'] == null
                            ? Text(
                                user['name'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: user['last_message'] != null
                          ? Text(
                              user['last_message'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: (user['unread_count'] ?? 0) > 0 ? Colors.black87 : Colors.grey,
                                fontWeight: (user['unread_count'] ?? 0) > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            )
                          : null,
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (user['last_message_time'] != null)
                            Text(
                              DateFormat('HH:mm').format(DateTime.parse(user['last_message_time']).toLocal()),
                              style: TextStyle(
                                fontSize: 12,
                                color: (user['unread_count'] ?? 0) > 0 ? Colors.green : Colors.grey,
                                fontWeight: (user['unread_count'] ?? 0) > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          if ((user['unread_count'] ?? 0) > 0) ...[
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text(
                                '${user['unread_count']}',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: user['id'],
                              otherUserName: user['name'],
                            ),
                          ),
                        ).then((_) => _fetchConversations());
                      },
                    );
                  },
                ),
    );
  }
}
