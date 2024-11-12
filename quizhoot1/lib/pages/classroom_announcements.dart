import 'package:flutter/material.dart';

// Main widget for Classroom Announcements page
class ClassroomAnnouncements extends StatefulWidget {
  const ClassroomAnnouncements({super.key});

  @override
  _ClassroomAnnouncementsState createState() => _ClassroomAnnouncementsState();
}

class _ClassroomAnnouncementsState extends State<ClassroomAnnouncements> {
  // List of sample announcements with user, initials, time, and message
  final List<Map<String, dynamic>> _announcements = [
    {
      'user': 'Teacher',
      'initials': 'T',
      'timeAgo': DateTime.now()
          .subtract(const Duration(minutes: 30)), // 30 minutes ago
      'announcement': 'Lecture will be in C301.',
    },
    {
      'user': 'me',
      'initials': 'A',
      'timeAgo': DateTime.now()
          .subtract(const Duration(minutes: 40)), // 40 minutes ago
      'announcement': 'Please submit your assignments by tomorrow.',
    },
    {
      'user': 'Teacher',
      'initials': 'T',
      'timeAgo': DateTime.now()
          .subtract(const Duration(minutes: 50)), // 50 minutes ago
      'announcement': 'Class will be cancelled next week.',
    },
  ];

  // Controller to manage the input field for new announcements
  final TextEditingController _controller = TextEditingController();

  // Method to add a new announcement to the top of the list
  void _addAnnouncement() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _announcements.insert(0, {
          'user': 'me',
          'initials': 'A', // User initial
          'timeAgo': DateTime.now(), // Current time of announcement
          'announcement': _controller.text,
        });
        _controller.clear(); // Clear the input field
      });
    }
  }

  // Helper method to calculate and display time passed since announcement
  String _getTimeAgo(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 1) {
      return 'just now';
    } else if (duration.inMinutes == 1) {
      return '1 minute ago';
    } else {
      return '${duration.inMinutes} minutes ago';
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Announcements'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor: const Color(0xFF3A1078), // Background color of the page
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post a New Announcement', // Header text for input section
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter announcement here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white24, // Input field background
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addAnnouncement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A1078), // Button color
              ),
              child: const Text('Add Announcement'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Announcements', // Header text for announcements list
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            if (_announcements.isEmpty)
              const Center(
                child: Text(
                  'No announcements yet!', // Display if no announcements
                  style: TextStyle(color: Colors.white60),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          _announcements[index]['initials']!, // User initials
                          style: const TextStyle(color: Color(0xFF3A1078)),
                        ),
                      ),
                      title: Text(_announcements[index]
                          ['announcement']!), // Announcement text
                      subtitle: Text(
                        '${_announcements[index]['user']} - ${_getTimeAgo(_announcements[index]['timeAgo'])}', // User and time ago
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
