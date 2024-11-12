import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text(
            'Notifications'), // App bar title for the Notifications page
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // Individual notification cards with title, description, and timestamp
          NotificationCard(
            title: 'New Assignment Available',
            description: 'You have a new assignment in Classroom 1.',
            time: '10 minutes ago',
          ),
          SizedBox(height: 10), // Space between notification cards
          NotificationCard(
            title: 'Classroom Update',
            description: 'The schedule for Classroom 2 has been updated.',
            time: '2 hours ago',
          ),
          SizedBox(height: 10),
          NotificationCard(
            title: 'New Message from Teacher',
            description: 'You have received a new message from Teacher A.',
            time: '1 day ago',
          ),
          SizedBox(height: 10),
          NotificationCard(
            title: 'Upcoming Test Reminder',
            description: 'Don\'t forget the test in Classroom 3 tomorrow.',
            time: '2 days ago',
          ),
          SizedBox(height: 10),
          NotificationCard(
            title: 'New Message from Teacher',
            description: 'The due date for the assignment is tomorrow at 10 am',
            time: '3 days ago',
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(
          initialIndex: 1), // Custom bottom navigation bar with initial index
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4, // Shadow effect for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, // Bold title text
              ),
            ),
            const SizedBox(height: 4), // Spacing between title and description
            Text(
              description,
              style: const TextStyle(fontSize: 14), // Description text
            ),
            const SizedBox(height: 8), // Spacing between description and time
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey, // Timestamp text in grey
              ),
            ),
          ],
        ),
      ),
    );
  }
}
