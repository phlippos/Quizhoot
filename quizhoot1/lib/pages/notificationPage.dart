import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Bildirim listesini tutmak için bir liste
  final List<Map<String, String>> notifications = [
    {
      'title': 'New Assignment Available',
      'description': 'You have a new assignment in Classroom 1.',
      'time': '10 minutes ago',
    },
    {
      'title': 'Classroom Update',
      'description': 'The schedule for Classroom 2 has been updated.',
      'time': '2 hours ago',
    },
    {
      'title': 'New Message from Teacher',
      'description': 'You have received a new message from Teacher A.',
      'time': '1 day ago',
    },
    {
      'title': 'Upcoming Test Reminder',
      'description': 'Don\'t forget the test in Classroom 3 tomorrow.',
      'time': '2 days ago',
    },
    {
      'title': 'New Message from Teacher',
      'description': 'The due date for the assignment is tomorrow at 10 am',
      'time': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification['title']!),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              // Eleman kaydırıldığında listeden silinir
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${notification['title']} dismissed'),
                ),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Column(
              children: [
                NotificationCard(
                  title: notification['title']!,
                  description: notification['description']!,
                  time: notification['time']!,
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(initialIndex: 1),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
