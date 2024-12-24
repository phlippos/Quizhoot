import 'package:flutter/material.dart';

class ClassroomFolders extends StatelessWidget {
  const ClassroomFolders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Folders'), // Title of the Folders page
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: Center(
        child: Text('Folders inside class'),
      ),
    );
  }
}

