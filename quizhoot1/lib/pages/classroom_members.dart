import 'package:flutter/material.dart';
import '../classes/Classroom.dart';

class ClassroomMembers extends StatefulWidget {
  const ClassroomMembers({super.key});

  @override
  _ClassroomMembersState createState() => _ClassroomMembersState();
}

class _ClassroomMembersState extends State<ClassroomMembers> {
  late Classroom _classroom;
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _members = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classroom = ModalRoute.of(context)?.settings.arguments as Classroom;
    _fetchMembers();
  }

  // Fetch the classroom members from the server using the classroom's getMembersOfClassroom method
  Future<void> _fetchMembers() async {
    try {
      // Assuming getMembersOfClassroom returns a List<Map<String, dynamic>> with member data
      await _classroom.fetchMembersOfClassroom();
      List<Map<String, dynamic>> members = _classroom.members;
      List<Map<String, dynamic>> teachers = [];
      List<Map<String, dynamic>> membersList = [];

      for (var member in members) {
        print(member['member_username']);
        if (member['user_role'] == true) {
          teachers.add(member); // Add to teacher list if user_role is true
        } else {
          membersList.add(member); // Add to members list if user_role is false
        }
      }

      setState(() {
        _teachers = teachers;
        _members = membersList;
      });
    } catch (e) {
      print('Error fetching members: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load members')),
      );
    }
  }


  // Function to show a bottom sheet with options to add members, share the link, or leave classroom
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
                    const SnackBar(content: Text('Share Classroom Link clicked')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Leave Classroom'),
                onTap: () {
                  Navigator.pop(context);
                  // to:do
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave Classroom clicked')),
                  );
                  // Here, you can also add logic to remove the member from the classroom
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Leave Classroom'),
                onTap: () {
                  Navigator.pop(context);
                  // to:do
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave Classroom clicked')),
                  );
                  // Here, you can also add logic to remove the member from the classroom
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
        title: const Text('Classroom Members'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teacher',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            // Display teachers dynamically
            if (_teachers.isNotEmpty) ...[
              ..._teachers.map((teacher) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      teacher['member_username'][0],
                      style: const TextStyle(color: Color(0xFF3A1078)),
                    ),
                  ),
                  title: Text(
                    teacher['member_username'],
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Teacher',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 20),
            const Text(
              'Members',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            // Display members dynamically
            Expanded(
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _members[index]['member_username'][0],
                        style: const TextStyle(color: Color(0xFF3A1078)),
                      ),
                    ),
                    title: Text(
                      _members[index]['member_username'],
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    subtitle: Text(
                      _members[index]['user_role'] == true ? 'Teacher' : 'Member',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: const Color.fromARGB(255, 150, 100, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
