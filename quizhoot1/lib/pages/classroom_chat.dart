import 'package:flutter/material.dart';

class ClassroomChat extends StatefulWidget {
  const ClassroomChat({Key? key}) : super(key: key);

  @override
  _ClassroomChatState createState() => _ClassroomChatState();
}

class _ClassroomChatState extends State<ClassroomChat> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, String>? _pinnedMessage;
  bool isSending = false;

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        isSending = true;
      });

      // TODO: Send message to the backend
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add({
            "sender": "Me",
            "text": _controller.text,
          });
          _controller.clear();
          isSending = false;
        });

        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _deleteMessage(int index) {
    setState(() {
      // TODO: Notify backend about message deletion
      _messages.removeAt(index);
    });
  }

  void _editMessage(int index) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController editController = TextEditingController(
          text: _messages[index]["text"],
        );
        return AlertDialog(
          title: const Text("Edit Message"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Enter new message"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // TODO: Update the message on the backend
                  _messages[index]["text"] = editController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _pinMessage(int index) {
    setState(() {
      // TODO: Notify backend about pinned message
      _pinnedMessage = _messages[index];
    });
  }

  void _showMessageOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text("Pin Message"),
              onTap: () {
                Navigator.pop(context);
                _pinMessage(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Message"),
              onTap: () {
                Navigator.pop(context);
                _editMessage(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                "Delete Message",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(index);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Chat'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: Column(
        children: [
          if (_pinnedMessage != null)
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3A1078), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "📌 Pinned Message",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF3A1078),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _pinnedMessage = null;
                            // TODO: Notify backend about unpinning the message
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pinnedMessage!["text"]!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message["sender"] == "Me";

                return GestureDetector(
                  onLongPress: () =>
                      _showMessageOptions(_messages.length - 1 - index),
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message["sender"]!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isMe
                                  ? const Color(0xFF3A1078)
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            message["text"]!,
                            style: TextStyle(
                              fontSize: 16,
                              color: isMe
                                  ? const Color(0xFF3A1078)
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isSending)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Sending...",
                style: TextStyle(color: Colors.grey[300], fontSize: 12),
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF3A1078)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
