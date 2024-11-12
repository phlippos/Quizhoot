import 'package:flutter/material.dart';

class ClassroomMembers extends StatefulWidget {
  const ClassroomMembers({super.key});

  @override
  _ClassroomMembersState createState() => _ClassroomMembersState();
}

class _ClassroomMembersState extends State<ClassroomMembers> {
  final List<String> _members = [
    'Abdullah',
    'Baba',
    'Pro'
  ]; // Sample list of members
  final String _teacherName = 'Teacher Name'; // Teacher's name

  // Function to show a bottom sheet with options to add members or share the link
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blueAccent),
                title: const Text('Add Member'),
                onTap: () {
                  Navigator.pop(context);
                  // Member addition process can be handled here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Member clicked')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.green),
                title: const Text('Share Classroom Link'),
                onTap: () {
                  Navigator.pop(context);
                  // Share classroom link process can be handled here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Share Classroom Link clicked')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Members'), // Title of the AppBar
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor:
          const Color(0xFF3A1078), // Background color of the screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teacher', // Label for the teacher
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _teacherName[
                      0], // Display the first letter of the teacher's name
                  style: const TextStyle(color: Color(0xFF3A1078)),
                ),
              ),
              title: Text(
                _teacherName,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Members', // Label for the list of members
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _members.length, // Number of members
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _members[index]
                            [0], // Display first letter of each member's name
                        style: const TextStyle(color: Color(0xFF3A1078)),
                      ),
                    ),
                    title: Text(
                      _members[index], // Display the member's name
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddOptions(context), // Show options when FAB is pressed
        backgroundColor: const Color.fromARGB(255, 150, 100, 255),
        child:
            const Icon(Icons.add), // Icon for adding new member or sharing link
      ),
    );
  }
}
