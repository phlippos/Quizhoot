import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizhoot/classes/User.dart';
import 'custom_bottom_nav.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late User _user;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = Provider.of<User>(context, listen: false);
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    await _user.fetchNotifications();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<User>(
        builder: (context, userProvider, child) {
          final notifications = _user.notifications;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.message),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  setState(() {
                    _user.deleteNotification(notifications[index].id!);

                    notifications.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${notification.message} dismissed'),
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
                      username: notification.username,
                      message: notification.message,
                      classroomName: notification.classroomName,
                      time: notification.getTimeDifference(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(initialIndex: 1),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String username;
  final String message;
  final String classroomName;
  final String time;

  const NotificationCard({
    super.key,
    required this.username,
    required this.message,
    required this.classroomName,
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
      child: Container(
        padding: const EdgeInsets.all(35),
        constraints: BoxConstraints(minHeight: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontSize: 18, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8), // Increased space between elements
            Text(
              message,
              style: const TextStyle(
                fontSize: 16, // Increased font size
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              classroomName,
              style: const TextStyle(
                fontSize: 16, // Increased font size
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
