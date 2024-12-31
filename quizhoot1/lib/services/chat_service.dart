// chat_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;
import '../classes/Chat_message.dart';
import 'base_service.dart';
import 'auth_services.dart';
import 'dart:io'; // For WebSocket.connect
import 'package:web_socket_channel/io.dart'; // For IOWebSocketChannel
import 'package:web_socket_channel/web_socket_channel.dart'; // For WebSocketChannel



class ChatService extends BaseService {
  static final ChatService _instance = ChatService._internal();
  WebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  bool _isConnecting = false;
  Timer? _reconnectionTimer;
  Timer? _heartbeatTimer;
  int? _currentClassroomId;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  ChatService._internal();

  static ChatService get instance => _instance;

  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<List<ChatMessage>?> fetchMessages(int classroomId) async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(getLink('chat-messages')! + '?classroom_id=$classroomId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList().reversed.toList();
      }
      print('Failed to fetch messages: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching messages: $e');
      return null;
    }
  }


  Future<void> connectToWebSocket(int classroomId) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _currentClassroomId = classroomId;

    try {
      final token = await AuthService.instance.getToken();
      if (token == null) {
        _isConnecting = false;
        throw Exception('No authentication token available');
      }

      final wsUrl = Uri.parse(getWebSocketUrl(classroomId, token));
      print('Connecting to WebSocket: $wsUrl');

      final socket = await WebSocket.connect(
        wsUrl.toString(),
      );

      _channel = IOWebSocketChannel(socket);

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleConnectionClosed,
        cancelOnError: false,
      );

      _startHeartbeat();
      _isConnecting = false;
      print('WebSocket connected successfully');
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _isConnecting = false;
      _scheduleReconnection();
    }
  }


  void _handleMessage(dynamic data) {
    try {
      print('Received data: $data');
      final jsonData = json.decode(data);

      if (jsonData['type'] == 'heartbeat_response') {
        print('Heartbeat response received');
        return;
      }

      final message = ChatMessage.fromJson(jsonData);
      print('Message received: $message');
      _messageController.add(message);
    } catch (e) {
      print('Error processing message: $e');
    }
  }


  void _handleError(error) {
    print('WebSocket error: $error');
    _scheduleReconnection();
  }

  void _handleConnectionClosed() {
    print('WebSocket connection closed');
    _scheduleReconnection();
  }

  void _scheduleReconnection() {
    _stopHeartbeat();
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(_reconnectDelay, () {
      if (_currentClassroomId != null) {
        print('Attempting to reconnect...');
        connectToWebSocket(_currentClassroomId!);
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add(json.encode({'type': 'heartbeat'}));
          print('Heartbeat sent');
        } catch (e) {
          print('Error sending heartbeat: $e');
          _scheduleReconnection();
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void sendMessage(String message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(json.encode({'message': message}));
        print('Message sent: $message');
      } catch (e) {
        print('Error sending message: $e');
        _scheduleReconnection();
      }
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }

  void closeConnection() {
    print('Closing WebSocket connection');
    _currentClassroomId = null;
    _reconnectionTimer?.cancel();
    _stopHeartbeat();
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    _isConnecting = false;
  }

  void dispose() {
    closeConnection();
    _messageController.close();
  }
}