import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'classroom_inside.dart'; // This file is added to navigate to the class details page
import "clasroom_creation.dart";

// Main page for the classroom view
class ClassroomViewPage extends StatelessWidget {
  const ClassroomViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // TabController length to handle the 3 tabs
      initialIndex: 2, // Set the initial tab to index 2 (last tab)
      child: Scaffold(
        appBar: CustomTopNav(initialIndex: 2), // Custom top navigation bar
        body:
            ClassroomContent(), // Main content of the page, which displays the classrooms
        backgroundColor:
            Color(0xFF3A1078), // Background color for the entire page
        bottomNavigationBar:
            CustomBottomNav(initialIndex: 2), // Custom bottom navigation bar
      ),
    );
  }
}

// The content that will be displayed in the body of the ClassroomViewPage
class ClassroomContent extends StatefulWidget {
  const ClassroomContent({super.key});

  @override
  _ClassroomContentState createState() => _ClassroomContentState();
}

class _ClassroomContentState extends State<ClassroomContent> {
  // List of classrooms
  final List<Map<String, String>> classrooms = [
    {
      'className': 'Class 1',
      'studentCount': '10 Students',
      'teacherName': 'Teacher A'
    },
    {
      'className': 'Class 2',
      'studentCount': '15 Students',
      'teacherName': 'Teacher B'
    },
    {
      'className': 'Class 3',
      'studentCount': '20 Students',
      'teacherName': 'Teacher C'
    },
  ];

  // Method to delete a classroom
  void _deleteClassroom(int index) {
    setState(() {
      classrooms.removeAt(index); // Remove the classroom at the specified index
    });
  }

  // Method to edit a classroom's name
  void _editClassroom(int index, String newName) {
    setState(() {
      classrooms[index]['className'] = newName; // Update the classroom name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < classrooms.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClassroomCard(
                className: classrooms[i]['className']!,
                studentCount: classrooms[i]['studentCount']!,
                teacherName: classrooms[i]['teacherName']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClassroomInside(),
                    ),
                  );
                },
                onDelete: () => _deleteClassroom(i), // Pass delete callback
                onEdit: (newName) =>
                    _editClassroom(i, newName), // Pass edit callback
              ),
            ),
          if (classrooms.isEmpty)
            const Text(
              'No classrooms available.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),
    );
  }
}

// A widget representing a classroom card with class details
class ClassroomCard extends StatelessWidget {
  final String className;
  final String studentCount;
  final String teacherName;
  final VoidCallback onTap;
  final VoidCallback onDelete; // New callback for deleting a classroom
  final Function(String) onEdit; // Callback for editing

  const ClassroomCard({
    super.key,
    required this.className,
    required this.studentCount,
    required this.teacherName,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap callback when the card is tapped
      child: Container(
        width: 300, // Width of the card
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the card
          borderRadius:
              BorderRadius.circular(12), // Rounded corners for the card
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 8, // Blur radius of the shadow
              offset: Offset(0, 2), // Shadow offset
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row for displaying class name with an icon
            Row(
              children: [
                const Icon(Icons.groups, size: 40), // Icon for groups
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    className, // Display the class name here
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Edit button - show edit dialog
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: () {
                    _showEditDialog(context, className, onEdit);
                  },
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF3A1078)),
                  onPressed: onDelete, // Call delete function
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row for displaying the number of students with an icon
            Row(
              children: [
                const Icon(Icons.person,
                    size: 20), // Icon for the number of students
                const SizedBox(width: 5),
                Text(studentCount), // Display the number of students
              ],
            ),
            const SizedBox(height: 4),
            // Row for displaying the teacher's name with an icon
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20), // Icon for teacher
                const SizedBox(width: 5),
                Text(teacherName), // Display the teacher's name
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show edit dialog to edit the classroom name
  void _showEditDialog(
      BuildContext context, String currentClassName, Function(String) onEdit) {
    TextEditingController controller =
        TextEditingController(text: currentClassName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Classroom Name'),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'Enter new classroom name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  onEdit(newName); // Call the onEdit callback with the new name
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
