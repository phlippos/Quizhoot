import 'package:flutter/material.dart';
import 'package:quizhoot/pages/custom_bottom_nav.dart';
import 'classroom_announcements.dart';
import 'classroom_members.dart';
import 'classroom_chat.dart';

class ClassroomInside extends StatefulWidget {
  const ClassroomInside({super.key});

  @override
  _ClassroomInsideState createState() => _ClassroomInsideState();
}

class _ClassroomInsideState extends State<ClassroomInside>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // TabController to handle the tabs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // Initialize the TabController with 3 tabs
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose the TabController when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom'), // Title of the AppBar
        bottom: TabBar(
          controller: _tabController, // Set the controller to the TabBar
          tabs: const [
            Tab(text: 'Notice Board'), // Tab for Notice Board
            Tab(text: 'Members'), // Tab for Members
            Tab(text: 'Chat'), // Tab for Chat
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Set the controller to the TabBarView
        children: const [
          ClassroomAnnouncements(), // Widget for Notice Board
          ClassroomMembers(), // Widget for Members
          ClassroomChat(), // Widget for Chat
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(
          initialIndex:
              2), // Custom bottom navigation bar with initial index set to 2
    );
  }
}
