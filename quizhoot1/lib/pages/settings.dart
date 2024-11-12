import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF3A1078), // Set the background color of the page
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3A1078), // Set the app bar background color
        title: const Text('Settings'), // Title of the settings page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                // Action to change the user's name
              },
              child: _buildSettingOption(
                  'Change Name'), // Build option for changing name
            ),
            const SizedBox(height: 16), // Space between options
            GestureDetector(
              onTap: () {
                // Action to change the user's password
              },
              child: _buildSettingOption(
                  'Change Password'), // Build option for changing password
            ),
            const SizedBox(height: 16), // Space between options
            GestureDetector(
              onTap: () {
                // Action to change sound settings
              },
              child: _buildSettingOption(
                  'Change Sound'), // Build option for changing sound
            ),
            const SizedBox(height: 16), // Space between options
            GestureDetector(
              onTap: () {
                // Action to delete the account
              },
              child: _buildSettingOption(
                  'Delete Account'), // Build option for deleting account
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
        borderRadius:
            BorderRadius.circular(12), // Round the corners of the container
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
}
