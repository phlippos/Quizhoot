import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:quizhoot/services/base_service.dart';
import 'package:quizhoot/services/auth_services.dart';
import '../classes/Chat_message.dart';

class ChatService extends BaseService {
  static final ChatService _instance = ChatService._internal();
  ChatService._internal();
  static ChatService get instance => _instance;

  WebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<void> connectToChat(int classroomId) async {
    final token = await AuthService.instance.getToken();
    final wsUrl = Uri.parse('${getLink('chat-connect')}/$classroomId');

    _channel = WebSocketChannel.connect(wsUrl);
    _channel!.stream.listen(
      (message) {
        final data = json.decode(message);
        _messageController.add(ChatMessage.fromJson(data));
      },
      onError: (error) {
        print('WebSocket error: $error');
        reconnect(classroomId);
      },
    );
  }

  Future<void> sendMessage(int classroomId, String content,
      {String? attachmentUrl}) async {
    final token = await AuthService.instance.getToken();

    final response = await http.post(
      Uri.parse(getLink('chat-send')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'classroom_id': classroomId,
        'content': content,
        'attachment_url': attachmentUrl,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  Future<List<ChatMessage>> getMessageHistory(int classroomId) async {
    final token = await AuthService.instance.getToken();

    final response = await http.get(
      Uri.parse('${getLink('chat-history')}/$classroomId'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load message history');
    }
  }

  void reconnect(int classroomId) {
    Future.delayed(
        const Duration(seconds: 5), () => connectToChat(classroomId));
  }

  void dispose() {
    _channel?.sink.close();
    _messageController.close();
  }
}
