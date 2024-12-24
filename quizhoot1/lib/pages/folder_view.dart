import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'folder_inside.dart';
import 'folder_creation.dart';
import 'package:quizhoot/classes/Folder.dart';  // <-- Your Folder model

class FolderViewPage extends StatefulWidget {
  const FolderViewPage({super.key});

  @override
  State<FolderViewPage> createState() => _FolderViewPageState();
}

class _FolderViewPageState extends State<FolderViewPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  /// Fetch folders from the server (or any data source).
  Future<void> _fetchFolders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      // If your Folder class has a static method like fetchFolders()
      final fetchedFolders = await Folder.fetchFolders();
      setState(() {
        _folders = fetchedFolders;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching folders: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// Deletes a folder both on server and locally
  Future<void> _deleteFolder(Folder folder) async {
    try {
      // If your Folder class has a remove() method
      await folder.remove();
      setState(() {
        _folders.remove(folder);
      });
    } catch (e) {
      print("Error deleting folder: $e");
      // Optionally show a snackbar or dialog
    }
  }

  /// Navigate to folder creation page to create a new folder
  void _goToCreateFolder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateFolderPage(),
      ),
    ).then((_) {
      // Refresh the folder list after returning from creation page
      _fetchFolders();
    });
  }

  /// Method to show the edit dialog
  void _editFolder(int index) async {
    TextEditingController _nameController = TextEditingController(
        text: _folders[index].name); // Pre-fill with current name

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
                Navigator.of(context).pop(_nameController.text); // Return new name
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
        _folders[index].name = newFolderName; // Update the folder name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: const CustomTopNav(initialIndex: 1),
        backgroundColor: const Color(0xFF3A1078),
        bottomNavigationBar: const CustomBottomNav(initialIndex: 2),

        // Show different UI based on loading/error states
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
            ? const Center(
          child: Text(
            'Error loading folders.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : _folders.isEmpty
            ? const Center(
          child: Text(
            'No folders available.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : FolderListView(
          folders: _folders,
          onDeleteFolder: _deleteFolder,
          onEditFolder: _editFolder,
        ),

        // Button to create a new folder
        floatingActionButton: FloatingActionButton(
          onPressed: _goToCreateFolder,
          backgroundColor: const Color.fromARGB(255, 237, 234, 240),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class FolderListView extends StatelessWidget {
  final List<Folder> folders;
  final void Function(Folder folder) onDeleteFolder;
  final void Function(int index) onEditFolder;

  const FolderListView({
    super.key,
    required this.folders,
    required this.onDeleteFolder,
    required this.onEditFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: folders.asMap().entries.map((entry) {
          int index = entry.key;
          Folder folder = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FolderCard(
              folder: folder,
              onTap: () {
                // Navigate to folder details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderInside(folder: folder),
                  ),
                );
              },
              onEdit: () => onEditFolder(index),
              onDelete: () => onDeleteFolder(folder),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // For display purposes, we assume folder has:
    // - folder.name
    // - folder.createdBy or some similar property
    // - a method to get item count: e.g. folder.sets.length or folder.itemCount
    final itemCount = folder.size; // If sets are eagerly loaded

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
                    folder.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: onEdit,
                ),
                // Delete button
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
                Text('$itemCount Items'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
