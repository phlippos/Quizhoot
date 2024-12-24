import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'folder_inside.dart';

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
  List<Map<String, String>> folders = [
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

  // Method to show the edit dialog
  void _editFolder(int index) async {
    TextEditingController _nameController = TextEditingController(
        text: folders[index]['folderName']); // Pre-fill with current name

    // Show dialog to edit the folder name
    String? newFolderName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Folder Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter new folder name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(_nameController.text); // Return new name
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // If the user provided a new folder name, update the folder list
    if (newFolderName != null && newFolderName.isNotEmpty) {
      setState(() {
        folders[index]['folderName'] = newFolderName; // Update the folder name
      });
    }
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
                onDelete: () => _deleteFolder(i), // Delete callback
                onEdit: () => _editFolder(i), // Edit callback
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
  final VoidCallback onDelete;
  final VoidCallback onEdit; // Edit callback

  const FolderCard({
    super.key,
    required this.folderName,
    required this.itemCount,
    required this.createdBy,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
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
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: onEdit, // Open edit dialog
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF3A1078)),
                  onPressed: onDelete,
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