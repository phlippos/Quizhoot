import 'package:flutter/material.dart';

class ClassroomChat extends StatefulWidget {
  const ClassroomChat({super.key});

  @override
  _ClassroomChatState createState() => _ClassroomChatState();
}

class _ClassroomChatState extends State<ClassroomChat> {
  // List to store messages and their senders
  final List<Map<String, String>> _messages = [
    {"sender": "Teacher", "text": "Welcome to the class chat!"},
    {"sender": "Abdullah", "text": "Hello everyone!"},
    {"sender": "Baba", "text": "Hi! Looking forward to learning together."},
  ];

  // Controller to manage the message input field
  final TextEditingController _controller = TextEditingController();

  // Function to send a message and add it to the message list
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        // Adds a new message with "Me" as the sender
        _messages.add({
          "sender": "Me",
          "text": _controller.text,
        });
        _controller.clear(); // Clears the input field after sending
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Chat'), // AppBar title
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor:
          const Color(0xFF3A1078), // Background color for the chat screen
      body: Column(
        children: [
          // Expanded widget to display the list of messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length, // Total number of messages
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar showing the initial of the sender
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Text(
                        message["sender"]![
                            0], // Displaying the first letter of the sender
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Spacing between avatar and message box
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white, // Message bubble color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Displaying sender name in bold
                            Text(
                              message["sender"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3A1078),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    5), // Spacing between sender name and message text
                            // Displaying message text
                            Text(
                              message["text"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3A1078),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Input area for typing a new message
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // TextField to enter message text
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText:
                          'Enter your message...', // Hint text for the input field
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // Send button to send the message
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF3A1078)),
                  onPressed:
                      _sendMessage, // Calls _sendMessage function on press
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
