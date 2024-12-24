import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizhoot/classes/Folder.dart';
import 'package:quizhoot/classes/Set.dart';
import 'package:quizhoot/classes/User.dart';

class CreateFolderPage extends StatefulWidget {
  const CreateFolderPage({super.key});

  @override
  _CreateFolderPageState createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final List<bool> setSelections = [];
  late List<Set> availableSets = [];
  String folderName = '';
  bool isCreating = false;
  Folder? createdFolder;

  @override
  void initState() {
    super.initState();
    _loadAvailableSets();
  }

  Future<void> _loadAvailableSets() async {
    final user = Provider.of<User>(context, listen: false);

    try {
      await user.fetchSets();  // Fetch sets from server
      setState(() {
        availableSets = user.getSets();
        setSelections.clear();
        setSelections.addAll(List<bool>.filled(availableSets.length, false));
      });
    } catch (e) {
      print('Error loading sets: $e');
    }
  }

  void _showFolderDialog() {

    final folderNameController = TextEditingController(text: folderName);


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Folder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: folderNameController,
                  onChanged: (value) => folderName = value,
                  decoration: const InputDecoration(
                    labelText: 'Folder Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Select Sets to Add'),
                Consumer<User>(
                  builder: (context, user, child) {
                    return Column(
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
                    );
                  },
                ),
              ],
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

                setState(() {
                  folderName = folderNameController.text.trim();
                });

                if (folderName.isNotEmpty) {
                  await _createFolderAndAddSets(folderName);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createFolderAndAddSets(String name) async {
    setState(() => isCreating = true);

    try {
      Folder newFolder = Folder.create(name);
      await newFolder.add();

      final user = Provider.of<User>(context, listen: false);
      for (int i = 0; i < setSelections.length; i++) {
        if (setSelections[i]) {
          final selectedSet = availableSets[i];
          await newFolder.addSetToFolder(selectedSet);
        }
      }

      setState(() {
        createdFolder = newFolder;
        isCreating = false;
      });
    } catch (e) {
      print('Error creating folder or adding sets: $e');
      setState(() => isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Folder Creation'),
      ),
      body: Center(
        child: isCreating
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (createdFolder == null) ...[
              const Text(
                'No folder created yet',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ] else ...[
              Text(
                'Folder: ${createdFolder!.name}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Selected Sets: ${_formatSelectedSets()}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFolderDialog,
        backgroundColor: const Color.fromARGB(255, 237, 234, 240),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatSelectedSets() {
    final selectedNames = <String>[];
    for (int i = 0; i < setSelections.length; i++) {
      if (setSelections[i]) {
        selectedNames.add(availableSets[i].name);
      }
    }
    return selectedNames.join(', ');
  }
}
