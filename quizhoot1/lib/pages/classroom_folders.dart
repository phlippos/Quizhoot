import 'package:flutter/material.dart';

class Folder {
  final String id;
  final String name;
  final String description;
  final int setCount;
  final DateTime createdAt;
  final String createdBy;

  Folder({
    required this.id,
    required this.name,
    required this.description,
    this.setCount = 0,
    required this.createdAt,
    required this.createdBy,
  });

  // Factory constructor to create a Folder from JSON
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      setCount: json['setCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  // Convert folder to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'setCount': setCount,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

class ClassroomFolders extends StatefulWidget {
  const ClassroomFolders({super.key});

  @override
  _ClassroomFoldersState createState() => _ClassroomFoldersState();
}

class _ClassroomFoldersState extends State<ClassroomFolders> {
  bool _isLoading = true;
  String? _error;
  List<Folder> _folders = [];
  late final String _classroomId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _classroomId = args?['classroomId'] as String? ?? '';
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Replace with actual API call
      // Example API call:
      // final response = await _folderService.getFoldersForClassroom(_classroomId);
      // _folders = response.map((json) => Folder.fromJson(json)).toList();

      // Temporary mock data
      await Future.delayed(const Duration(seconds: 1));
      _folders = [
        Folder(
          id: '1',
          name: 'Homework',
          description: 'Daily homework assignments',
          setCount: 5,
          createdAt: DateTime.now(),
          createdBy: 'user123',
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load folders: $e';
      });
    }
  }

  Future<void> _createFolder(String name, String description) async {
    try {
      // TODO: Replace with actual API call
      // Example API call:
      // final newFolder = await _folderService.createFolder(
      //   classroomId: _classroomId,
      //   name: name,
      //   description: description,
      // );

      // Temporary mock implementation
      final newFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        createdAt: DateTime.now(),
        createdBy: 'currentUser', // TODO: Replace with actual user ID
      );

      setState(() {
        _folders.add(newFolder);
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

  Future<void> _deleteFolder(String folderId) async {
    try {
      // TODO: Replace with actual API call
      // await _folderService.deleteFolder(folderId);

      setState(() {
        _folders.removeWhere((folder) => folder.id == folderId);
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
        key: Key(folder.id),
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
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        onDismissed: (direction) => _deleteFolder(folder.id),
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
              '/folderContent',
              arguments: {
                'folderId': folder.id,
                'folderName': folder.name,
              },
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
                        folder.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${folder.setCount} sets',
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
                        onPressed: _loadFolders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFolders,
                  child: _folders.isEmpty
                      ? const Center(
                          child: Text(
                            'No folders yet',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _folders.length,
                          itemBuilder: (context, index) =>
                              _buildFolderCard(_folders[index]),
                        ),
                ),
    );
  }

  Future<void> _showAddFolderDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

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
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter folder description',
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
                  descriptionController.text,
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
