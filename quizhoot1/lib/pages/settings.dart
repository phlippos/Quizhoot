import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/User.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late User user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user =  Provider.of<User>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Set the background color of the page
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078), // Set the app bar background color
        title: const Text('Settings'), // Title of the settings page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                _showNameInputDialog(context); // Show input dialog for name change
              },
              child: _buildSettingOption('Change Name'), // Build option for changing name
            ),
            const SizedBox(height: 16), // Space between options
            GestureDetector(
              onTap: () {
                _showPasswordInputDialog(context); // Show input dialog for password change
              },
              child: _buildSettingOption('Change Password'), // Build option for changing password
            ),
            const SizedBox(height: 16), // Space between options
            GestureDetector(
              onTap: () {
                _showDeleteConfirmationDialog(context); // Show delete confirmation dialog
              },
              child: _buildSettingOption('Delete Account'), // Build option for deleting account
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build individual setting options
  Widget _buildSettingOption(String title) {
    return Container(
      width: double.infinity, // Make the container take up full width
      padding: const EdgeInsets.all(16), // Add padding inside the container
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color of the option
        borderRadius: BorderRadius.circular(12), // Round the corners of the container
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // Set the color of the shadow
            blurRadius: 8, // Set the blur radius of the shadow
            offset: Offset(0, 2), // Set the offset of the shadow
          ),
        ],
      ),
      child: Center(
        child: Text(
          title, // Display the title of the setting option
          style: const TextStyle(fontSize: 18), // Set the text style
        ),
      ),
    );
  }

  // Method to show an input dialog for changing name
  void _showNameInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new username',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  user.username = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to show an input dialog for changing password
  void _showPasswordInputDialog(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Enter current password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Enter new password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmNewPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Confirm new password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the password change
                if (currentPasswordController.text == user.password) {
                  if (newPasswordController.text == confirmNewPasswordController.text) {
                    setState(() {
                      user.password = newPasswordController.text;
                    });
                    Navigator.of(context).pop();
                  } else {
                    // Show error message: new password and confirm password do not match
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text('New password and confirm password do not match.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // Show error message: current password is incorrect
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text('Current password is incorrect.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to show a confirmation dialog for deleting the account
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                // Handle account deletion
                user.delete();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
