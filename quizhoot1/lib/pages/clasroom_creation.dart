import 'package:flutter/material.dart';
import 'package:quizhoot/pages/custom_bottom_nav.dart';

class CreateClassroomPage extends StatelessWidget {
  const CreateClassroomPage({super.key});

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

  void _showCreateClassroomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Modal ekranı tam açılabilir yapar.
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
              const SizedBox(height: 12),
              _buildTextField('Section'),
              const SizedBox(height: 12),
              _buildTextField('Subject'),
              const SizedBox(height: 12),
              _buildTextField('Room'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3A1078),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Handle classroom creation
                  Navigator.pop(context); // Close the modal
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
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
