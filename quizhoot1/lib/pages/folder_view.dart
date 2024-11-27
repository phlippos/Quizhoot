import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'folder_inside.dart';
import 'folder_creation.dart'; // Import flashcard creation page

class FolderViewPage extends StatelessWidget {
  const FolderViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: CustomTopNav(initialIndex: 1),
        body: FolderContent(),
        backgroundColor: Color(0xFF3A1078),
        bottomNavigationBar: CustomBottomNav(initialIndex: 2),
      ),
    );
  }
}

class FolderContent extends StatefulWidget {
  const FolderContent({super.key});

  @override
  _FolderContentState createState() => _FolderContentState();
}

class _FolderContentState extends State<FolderContent> {
  // List of folders
  final List<Map<String, String>> folders = [
    {'folderName': 'Folder 1', 'itemCount': '10 Items', 'createdBy': 'User A'},
    {'folderName': 'Folder 2', 'itemCount': '15 Items', 'createdBy': 'User B'},
    {'folderName': 'Folder 3', 'itemCount': '20 Items', 'createdBy': 'User C'},
  ];

  // Method to delete a folder
  void _deleteFolder(int index) {
    setState(() {
      folders.removeAt(index); // Remove the folder at the specified index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < folders.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FolderCard(
                folderName: folders[i]['folderName']!,
                itemCount: folders[i]['itemCount']!,
                createdBy: folders[i]['createdBy']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FolderInside(),
                    ),
                  );
                },
                onDelete: () => _deleteFolder(i), // Pass delete callback
              ),
            ),
          if (folders.isEmpty)
            const Text(
              'No folders available.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),
    );
  }
}

class FolderCard extends StatelessWidget {
  final String folderName;
  final String itemCount;
  final String createdBy;
  final VoidCallback onTap;
  final VoidCallback onDelete; // New callback for deleting a folder

  const FolderCard({
    super.key,
    required this.folderName,
    required this.itemCount,
    required this.createdBy,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    folderName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Edit button - navigate to folder creation page
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateFolderPage(),
                      ),
                    );
                  },
                ),
                // Delete button - call the delete function
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF3A1078)),
                  onPressed: onDelete, // Call delete function
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 20),
                const SizedBox(width: 5),
                Text(itemCount),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 5),
                Text(createdBy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
