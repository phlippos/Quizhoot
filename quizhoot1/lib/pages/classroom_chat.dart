import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/Chat_message.dart';
import '../services/chat_service.dart';
import '../classes/User.dart';

class ClassroomChat extends StatefulWidget {
  final int classroomId;

  const ClassroomChat({
    super.key,
    required this.classroomId,
  });

  @override
  _ClassroomChatState createState() => _ClassroomChatState();
}

class _ClassroomChatState extends State<ClassroomChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late final ChatService _chatService;
  late final User _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService.instance;
    _currentUser = Provider.of<User>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Load message history
      final messages = await _chatService.getMessageHistory(widget.classroomId);
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });

      // Connect to WebSocket
      await _chatService.connectToChat(widget.classroomId);
      _chatService.messageStream.listen(_handleNewMessage);
    } catch (e) {
      _showError('Failed to initialize chat: $e');
    }
  }

  void _handleNewMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(
        widget.classroomId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    _chatService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        message: message,
                        isMe: message.senderId == _currentUser.id.toString(),
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
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implement file attachment
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
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

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
