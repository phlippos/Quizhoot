import 'package:flutter/material.dart';
import 'package:quizhoot/pages/custom_bottom_nav.dart';

/// Page for creating a new classroom
class CreateClassroomPage extends StatelessWidget {
  const CreateClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Set the page background color
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3A1078), // Set the AppBar background color
        title: const Text('Create Classroom'), // Displayed title in AppBar
      ),
      body: const Center(
        child: Text('Classroom Creation Screen'), // Centered text on the screen
      ),
      bottomNavigationBar: const CustomBottomNav(
          initialIndex: 2), // Bottom navigation with default tab selection
    );
  }
}
