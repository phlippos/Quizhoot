import 'package:flutter/material.dart';
import 'package:quizhoot/pages/custom_bottom_nav.dart';
import 'package:quizhoot/classes/Classroom.dart'; // Import the Classroom model

class CreateClassroomPage extends StatefulWidget {
  const CreateClassroomPage({super.key});

  @override
  _CreateClassroomPageState createState() => _CreateClassroomPageState();
}

class _CreateClassroomPageState extends State<CreateClassroomPage> {
  final _classroomNameController = TextEditingController(); // Controller for the classroom name input
  bool _isCreating = false; // To show loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Create Classroom'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showCreateClassroomModal(context),
          child: const Text('+ Create Classroom'),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(initialIndex: 2),
    );
  }

  // Show the modal for creating a classroom
  void _showCreateClassroomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3A1078),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Classroom',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Classroom Name'),
              const SizedBox(height: 20),
              _isCreating
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3A1078),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  _createClassroom(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle classroom creation
  Future<void> _createClassroom(BuildContext context) async {
    final classroomName = _classroomNameController.text.trim();
    if (classroomName.isEmpty) {
      _showErrorDialog(context, 'Classroom name cannot be empty!');
      return;
    }

    setState(() {
      _isCreating = true; // Set loading state
    });

    try {
      // Use Classroom model and ClassroomService to create classroom
      final classroom = Classroom.create(classroomName);
      final response = await classroom.add();
      if (response.statusCode == 201) {
        // Successfully created the classroom
        Navigator.pop(context); // Close the modal
        _showSuccessDialog(context, 'Classroom created successfully!');
      } else {
        // Failed to create classroom
        _showErrorDialog(context, 'Failed to create classroom!');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error: $e');
    } finally {
      setState(() {
        _isCreating = false; // Reset loading state
      });
    }
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // TextField widget for classroom name
  Widget _buildTextField(String label) {
    return TextField(
      controller: _classroomNameController, // Bind the controller to the text field
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}