import 'package:flutter/material.dart';
import 'set_view.dart'; // Add the necessary page files
import 'folder_view.dart';
import 'classroom_view.dart';

class CustomTopNav extends StatelessWidget implements PreferredSizeWidget {
  final int initialIndex;

  const CustomTopNav({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(
          0xFF3A1078), // Custom background color for the top navigation bar
      bottom: TabBar(
        indicatorColor: Colors
            .white, // Set the color of the tab indicator (line below the selected tab)
        labelColor: Colors.white, // Color for the selected tab's label
        unselectedLabelColor:
            Colors.grey, // Color for the unselected tab's label
        onTap: (index) {
          // Navigate to the corresponding page based on the tab selected
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const FlashcardViewPage()), // Navigate to the Flashcard view
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const FolderViewPage()), // Navigate to the Folder view
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ClassroomViewPage()), // Navigate to the Classroom view
              );
              break;
          }
        },
        tabs: const [
          Tab(text: 'Sets'), // Tab for Flashcards
          Tab(text: 'Folders'), // Tab for Folders
          Tab(text: 'Classroom'), // Tab for Classroom
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(100); // Set the preferred size for the AppBar
}