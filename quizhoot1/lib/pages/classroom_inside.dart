import 'package:flutter/material.dart';
import 'package:quizhoot/pages/custom_bottom_nav.dart';
import 'classroom_announcements.dart';
import 'classroom_members.dart';
import 'classroom_chat.dart';
import 'classroom_folders.dart'; // Import the new Folder page

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
        length: 4,
        vsync: this,
        initialIndex: 0); // Set initialIndex to 0 or a valid index
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
            Tab(text: 'Folders'), // New Tab for Folders
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Set the controller to the TabBarView
        children: const [
          ClassroomAnnouncements(), // Widget for Notice Board
          ClassroomMembers(), // Widget for Members
          ClassroomChat(), // Widget for Chat
          ClassroomFolders(), // Widget for Folders
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(
          initialIndex: 0), // Set the initialIndex correctly within the range
    );
  }
}
