import 'package:flutter/material.dart';
import 'package:quizhoot/classes/Classroom.dart'; // Assuming the Classroom class is in this file
import '../classes/CNotification.dart';

// Main widget for Classroom Announcements page
class ClassroomAnnouncements extends StatefulWidget {
  const ClassroomAnnouncements({super.key});

  @override
  _ClassroomAnnouncementsState createState() => _ClassroomAnnouncementsState();
}

class _ClassroomAnnouncementsState extends State<ClassroomAnnouncements> {
  late Classroom classroom; // To hold the classroom object
  final TextEditingController _controller = TextEditingController();

  // List of announcements (initially empty until fetched)
  List<CNotification> _announcements = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get classroom object passed through ModalRoute
    classroom = ModalRoute.of(context)?.settings.arguments as Classroom;

    // Fetch the notifications for this classroom
    _fetchNotifications();
  }

  // Method to fetch notifications from classroom
  Future<void> _fetchNotifications() async {
    try {
      // Assuming the classroom object has a fetchNotifications method
      await classroom.fetchNotifications();
      setState(() {
        _announcements = classroom.getCNotifications();

      });
    } catch (error) {
      // Handle error fetching notifications
      print("Error fetching notifications: $error");
    }
  }

  // Method to add a new announcement
  // Method to add a new announcement
  void _addAnnouncement() async {
    if (_controller.text.isNotEmpty) {
      try {
        // Create the notification object
        CNotification newNotification = CNotification.create(
          classroom.id!, // Pass classroom ID
          _controller.text, // Message from input field
        );

        // Call the service to add the notification to the database
        await newNotification.add();

        // If the notification is successfully created, update the UI
        setState(() {
          _announcements.add(newNotification);
        });
        _controller.clear(); // Clear the input field
      } catch (e) {
        // Handle error if notification creation fails
        print("Failed to add notification: $e");
      }
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Announcements'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post a New Announcement',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter announcement here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white24,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addAnnouncement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A1078),
              ),
              child: const Text('Add Announcement'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Announcements',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            if (_announcements.isEmpty)
              const Center(
                child: Text(
                  'No announcements yet!',
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
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                            "M",
                          style: TextStyle(color: Color(0xFF3A1078)),
                        ),
                      ),
                      title: Text(_announcements[index].message),
                      subtitle: Text(
                        '${_announcements[index].username} - ${_announcements[index].getTimeDifference()}',
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
