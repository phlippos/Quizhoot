import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'auth_services.dart';
import 'package:quizhoot/classes/Chat_message.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  late WebSocketChannel _channel;

  ChatService._internal();

  static ChatService get instance => _instance;

  void connectToChat(int classroomId) async {
    final token = await AuthService.instance.getToken();  // Await the async method
    final url = 'ws://127.0.0.1:8000/ws/chat/$classroomId/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  // Send a message via WebSocket
  void sendMessage(String content) {
    _channel.sink.add(jsonEncode({'message': content}));
  }

  // Listen for incoming WebSocket messages
  Stream<dynamic> get messageStream => _channel.stream;

  // Disconnect from WebSocket
  void disconnect() {
    _channel.sink.close();
  }

  // Fetch message history from server
  Future<List<ChatMessage>> fetchChatHistory(int classroomId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/chat-history/$classroomId/'),
      headers: {
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }
}
