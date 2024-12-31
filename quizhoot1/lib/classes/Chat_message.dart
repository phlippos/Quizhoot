// chat_message.dart
class ChatMessage {
  final String message;
  final String username;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.username,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['content'] as String,  // 'content' is the server key for message
      username: json['sender_username'] as String,  // 'sender_username' is the server key for username
      timestamp: DateTime.parse(json['timestamp'] as String),  // 'timestamp' remains the same
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'username': username,
    'timestamp': timestamp.toIso8601String(),
  };
}
