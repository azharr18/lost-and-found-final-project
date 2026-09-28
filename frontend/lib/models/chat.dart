class Chat {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
