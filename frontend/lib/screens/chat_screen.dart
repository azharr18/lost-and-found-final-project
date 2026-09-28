import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/chat.dart';
import '../models/item.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final Item? itemContext;
  final String? otherUserName;

  const ChatScreen({Key? key, required this.otherUserId, this.itemContext, this.otherUserName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  List<Chat> _chats = [];
  Timer? _pollingTimer;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    ChatService.markRead(widget.otherUserId);
    _loadUserAndChats();
    _startPolling();
    _sendInitialItemContext();
  }

  Future<void> _loadUserAndChats() async {
    final user = await AuthService.getProfile();
    if (!mounted) return;
    if (user != null) {
      setState(() => _currentUserId = user.id);
    }
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final chats = await ChatService.getChats(widget.otherUserId);
    if (!mounted) return;
    setState(() {
      _chats = chats;
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchChats();
    });
  }

  void _sendInitialItemContext() async {
    if (widget.itemContext != null) {
      final chats = await ChatService.getChats(widget.otherUserId);
      if (chats.isEmpty) {
        String msg = "Halo, saya menghubungi terkait item: ${widget.itemContext!.name}";
        await ChatService.sendMessage(widget.otherUserId, msg);
        _fetchChats();
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String text = _messageController.text.trim();
    _messageController.clear();
    await ChatService.sendMessage(widget.otherUserId, text);
    _fetchChats();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName ?? 'Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final isMe = chat.senderId == _currentUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppConstants.primaryBlue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      chat.message,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppConstants.primaryBlue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
