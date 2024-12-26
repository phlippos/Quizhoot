import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/User.dart';
import 'custom_top_nav.dart';       // Custom top navigation widget
import 'custom_bottom_nav.dart';   // Custom bottom navigation widget
import 'set_inside.dart';          // Page showing individual set details

// Suppose you have these in your project:
import 'package:quizhoot/classes/Folder.dart';
import 'package:quizhoot/classes/Set.dart';

class ClassroomFolderInside extends StatefulWidget {
  const ClassroomFolderInside({super.key});

  @override
  State<ClassroomFolderInside> createState() => _ClassroomFolderInsideState();
}

class _ClassroomFolderInsideState extends State<ClassroomFolderInside> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Set> _sets = [];
  late Folder _folder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchFolderSets();
  }

  /// Fetch sets from the server for this folder
  Future<void> _fetchFolderSets() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _folder = ModalRoute.of(context)?.settings.arguments as Folder;
      final folderSets = await _folder.fetchSetsInFolder();
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
      await _folder.removeSetFromFolder(set);
      setState(() {
        _sets.remove(set);
        _folder.size--;
      });
    } catch (e) {
      print("Error deleting set: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete set')),
      );
    }
  }

  void _editSet(Set set) {
    Navigator.pushNamed(context, '/flashcardUpdate', arguments: set);
  }

  void _showAddSetDialog() {
    List<Set> availableSets = [];
    List<bool> setSelections = [];

    Future<void> _loadAvailableSets() async {
      final user = Provider.of<User>(context, listen: false);
      try {
        setState(() {
          availableSets = user.getSets();
          setSelections = List<bool>.filled(availableSets.length, false);
        });
      } catch (e) {
        print('Error loading sets: $e');
      }
    }

    _loadAvailableSets();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sets'),
          content: availableSets.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(availableSets.length, (index) {
                return CheckboxListTile(
                  title: Text(availableSets[index].name),
                  value: setSelections[index],
                  onChanged: (bool? value) {
                    setState(() {
                      setSelections[index] = value ?? false;
                    });
                  },
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                for (int i = 0; i < setSelections.length; i++) {
                  if (setSelections[i]) {
                    await _folder.addSetToFolder(availableSets[i]);
                    _folder.size++;
                  }
                }
                _fetchFolderSets();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A1078),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Pop the current page off the navigation stack
            },
          ),
          title: const Text('Folder Details'),
        ),
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
            : SetListView(sets: _sets, onDelete: _deleteSet, onEdit: _editSet),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddSetDialog,
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.blue),
        ),
      ),
    );
  }
}

class SetListView extends StatelessWidget {
  final List<Set> sets;
  final Function(Set) onDelete;
  final Function(Set) onEdit;

  const SetListView({super.key, required this.sets, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: sets.length,
      separatorBuilder: (context, _) => const SizedBox(height: 16),
      itemBuilder: (ctx, index) {
        final setData = sets[index];
        return ClassroomSetListView(
          setName: setData.name,
          termCount: '${setData.size} Terms',
          onTap: () {
            // Navigate to the SetInside page (pass the set as an argument)
            Navigator.pushNamed(context, '/setInside', arguments: setData);
          },
          onDelete: () => onDelete(setData),
          onEdit: () => onEdit(setData),
        );
      },
    );
  }
}

class ClassroomSetListView extends StatelessWidget {
  final String setName;
  final String termCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ClassroomSetListView({
    super.key,
    required this.setName,
    required this.termCount,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
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
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: onEdit,
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
