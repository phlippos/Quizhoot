import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizhoot/classes/Classroom.dart';
import '../classes/Folder.dart';
import '../classes/IComponent.dart';
import '../classes/Set.dart';

class ClassroomFolders extends StatefulWidget {
  const ClassroomFolders({super.key});

  @override
  _ClassroomFoldersState createState() => _ClassroomFoldersState();
}

class _ClassroomFoldersState extends State<ClassroomFolders> {
  bool _isLoading = true;
  String? _error;
  late List<IComponent> _components;
  late Classroom _classroom;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _classroom = ModalRoute.of(context)?.settings.arguments as Classroom;

      // Load components (sets and folders)
      await _classroom.listSetsAndFolders();
      _components = _classroom.components;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load components: $e';
      });
    }
  }

  Future<void> _createFolder(String name) async {
    try {
      final newFolder = Folder.create(name);
      await newFolder.add();
      await _classroom.addFolder(newFolder.id!);
      _classroom.addComponent(newFolder);

      setState(() {
        _components;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create folder: $e')),
      );
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    try {
      folder.remove();
      setState(() {
        _components.remove(folder);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete folder: $e')),
      );
    }
  }

  Widget _buildFolderCard(Folder folder) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Dismissible(
        key: Key(folder.id.toString()),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Folder'),
            content: Text('Are you sure you want to delete "${folder.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        onDismissed: (direction) => _deleteFolder(folder),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/classroomFolderInside',
              arguments: folder,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A1078).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Color(0xFF3A1078),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${folder.size} sets',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFolderDialog(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComponents,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadComponents,
        child: _components.isEmpty
            ? const Center(
          child: Text(
            'No components yet',
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _components.length,
          itemBuilder: (context, index) {
            final component = _components[index];
            if (component is Folder) {
              return _buildFolderCard(component);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _showAddFolderDialog() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Folder Name',
                hintText: 'Enter folder name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createFolder(
                  nameController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
