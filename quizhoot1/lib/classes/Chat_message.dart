class ChatMessage {
  final String id;
  final String senderName;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderName: json['sender_name'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
