import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quizhoot/services/chat_service.dart';
import '../classes/Chat_message.dart';

class ClassroomChat extends StatefulWidget {
  final int classroomId;

  const ClassroomChat({Key? key, required this.classroomId}) : super(key: key);

  @override
  State<ClassroomChat> createState() => _ClassroomChatState();
}

class _ClassroomChatState extends State<ClassroomChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  late final ChatService _chatService;
  late final StreamSubscription _messageSubscription;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService.instance;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Connect to WebSocket
      _chatService.connectToChat(widget.classroomId);

      // Fetch message history
      final messages = await _chatService.fetchChatHistory(widget.classroomId);
      setState(() {
        _messages = messages;
      });

      // Listen for new messages
      _messageSubscription = _chatService.messageStream.listen((event) {
        final message = ChatMessage.fromJson(jsonDecode(event));
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      });
    } catch (e) {
      _showError('Failed to initialize chat: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      _chatService.sendMessage(content);
      _messageController.clear();
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _chatService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classroom Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message.senderName),
                  subtitle: Text(message.content),
                  trailing: Text('${message.timestamp.hour}:${message.timestamp.minute}'),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
