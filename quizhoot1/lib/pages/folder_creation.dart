import 'package:flutter/material.dart';

class CreateFolderPage extends StatefulWidget {
  const CreateFolderPage({super.key});

  @override
  _CreateFolderPageState createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final List<String> availableSets = [
    'Set 1',
    'Set 2',
    'Set 3',
    'Set 4'
  ]; // List of available sets
  final List<bool> setSelections = [
    false,
    false,
    false,
    false
  ]; // Tracks selected sets
  String folderName = ''; // Stores the folder name entered by the user

  void _showFolderDialog() {
    TextEditingController folderNameController =
    TextEditingController(); // Controller for the folder name input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Folder'), // Dialog title
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: folderNameController, // Folder name input
                  onChanged: (value) {
                    folderName = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Folder Name', // Placeholder for folder name
                    border: OutlineInputBorder(), // Input border style
                  ),
                ),
                const SizedBox(height: 10), // Spacing between input and text
                const Text(
                    'Select Sets to Add'), // Instruction for selecting sets
                ...List.generate(availableSets.length, (index) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return CheckboxListTile(
                        title: Text(availableSets[index]), // Displays set name
                        value: setSelections[
                        index], // Checks if the set is selected
                        onChanged: (bool? value) {
                          setState(() {
                            setSelections[index] =
                                value ?? false; // Updates selection state
                          });
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Closes the dialog without saving
              },
              child: const Text('Cancel'), // Cancel button text
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  folderName =
                      folderNameController.text; // Sets the folder name
                });
                Navigator.pop(context); // Closes the dialog after saving
              },
              child: const Text('Create'), // Create button text
            ),
          ],
        );
      },
    );
  }

  void _saveFolder() {
    // Save functionality
    List<String> selectedSets = setSelections
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => availableSets[entry.key])
        .toList();

    if (folderName.isNotEmpty && selectedSets.isNotEmpty) {
      // Show a snackbar with folder name and selected sets
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Folder "$folderName" with sets ${selectedSets.join(', ')} saved!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show an error snackbar if folder name or selected sets are missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Please provide a valid name and select at least one set.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Background color of the page
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078), // AppBar background color
        title: const Text('Folder Creation'), // AppBar title
        actions: [
          IconButton(
            icon: const Icon(Icons.save), // Save icon
            onPressed: _saveFolder, // Trigger save functionality on press
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers the column
          children: [
            if (folderName.isNotEmpty) ...[
              // Checks if a folder name exists
              Text(
                'Folder: $folderName', // Displays folder name
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(
                  height: 10), // Spacing between folder name and sets
              Text(
                'Selected Sets: ${setSelections.asMap().entries.where((entry) => entry.value).map((entry) => availableSets[entry.key]).join(', ')}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16), // Displays selected sets
              ),
            ] else
              const Text(
                'No folder created yet', // Message when no folder is created
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFolderDialog, // Opens dialog to create folder
        backgroundColor:
        const Color.fromARGB(255, 237, 234, 240), // Button background color
        child: const Icon(Icons.add), // Icon for the floating button
      ),
    );
  }
}