import 'package:flutter/material.dart';
import 'custom_top_nav.dart';       // Custom top navigation widget
import 'custom_bottom_nav.dart';   // Custom bottom navigation widget
import 'set_inside.dart';          // Page showing individual set details

// Suppose you have these in your project:
import 'package:quizhoot/classes/Folder.dart';
import 'package:quizhoot/classes/Set.dart';

class FolderInside extends StatefulWidget {
  final Folder folder;

  // If you push here using Navigator, pass a Folder object:
  // Navigator.pushNamed(context, '/folderInside', arguments: myFolder);
  const FolderInside({super.key, required this.folder});

  @override
  State<FolderInside> createState() => _FolderInsideState();
}

class _FolderInsideState extends State<FolderInside> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Set> _sets = [];

  @override
  void initState() {
    super.initState();
    _fetchFolderSets();
  }

  /// Fetch sets from the server for this folder
  Future<void> _fetchFolderSets() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // fetchSetsInFolder() is a method from your Folder class
      // that calls the server to get sets for a specific folder.
      final folderSets = await widget.folder.fetchSetsInFolder();
      setState(() {
        _sets = folderSets;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching sets for folder: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _deleteSet(Set set) async {
    try {
      await widget.folder.removeSetFromFolder(set); // Assume delete() is a method in the Set class that deletes the set
      setState(() {
        _sets.remove(set);
      });
    } catch (e) {
      print("Error deleting set: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete set')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,         // Number of tabs
        initialIndex: 1,   // Sets the initial tab index
        child: Scaffold(
        appBar: const CustomTopNav(initialIndex: 1),
    backgroundColor: const Color(0xFF3A1078),
    bottomNavigationBar: const CustomBottomNav(initialIndex: 2),
    body: _isLoading
    ? const Center(child: CircularProgressIndicator())
        : _hasError
    ? const Center(
    child: Text(
    'Error loading folder sets.',
    style: TextStyle(color: Colors.white),
    ),
    )
        : _sets.isEmpty
    ? const Center(
    child: Text(
    'No sets found in this folder.',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    )
        : SetListView(sets: _sets, onDelete: _deleteSet),
        ),
    );
  }
}

class SetListView extends StatelessWidget {
  final List<Set> sets;
  final Function(Set) onDelete;

  const SetListView({super.key, required this.sets, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: sets.length,
      separatorBuilder: (context, _) => const SizedBox(height: 16),
      itemBuilder: (ctx, index) {
        final setData = sets[index];
        return SetCard(
          setName: setData.name,
          termCount: '${setData.size} Terms',
          onTap: () {
            // Navigate to the SetInside page (pass the set as an argument)
            Navigator.pushNamed(context, '/setInside', arguments: setData);
          },
          onDelete: () => onDelete(setData),
        );
      },
    );
  }
}

class SetCard extends StatelessWidget {
  final String setName;
  final String termCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SetCard({
    super.key,
    required this.setName,
    required this.termCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Execute the onTap function when tapped
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_list_numbered, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    setName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20),
                const SizedBox(width: 5),
                Text(termCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
