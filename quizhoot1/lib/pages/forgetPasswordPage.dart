import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  // Controllers to manage the input text fields
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Boolean to check if the new password and confirm password match
  bool _passwordsMatch = false;

  // Method to compare the new password and confirm password fields
  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _newPasswordController.text == _confirmPasswordController.text &&
              _newPasswordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen dimensions to adapt UI to different device sizes
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Purple background color
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05), // Responsive horizontal padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.05), // Space for top padding
              // App title
              Text(
                'Quizhoot',
                style: TextStyle(
                  fontSize: width * 0.09,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: Offset(width * 0.01, height * 0.01),
                      blurRadius: width * 0.02,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Additional spacing
              Center(
                child: Column(
                  children: [
                    // Main title of the page
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Instructional text
                    Text(
                      'Enter your username or email and set a new password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.045,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Username or email input field
                    TextField(
                      controller: _usernameOrEmailController,
                      decoration: const InputDecoration(
                        hintText: 'Username or Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white, // White background
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                    // New password input field
                    TextField(
                      controller: _newPasswordController,
                      onChanged: (value) => _checkPasswordsMatch(),
                      obscureText: true, // Hides the text for password security
                      decoration: const InputDecoration(
                        hintText: 'New Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    // Confirm password input field
                    TextField(
                      controller: _confirmPasswordController,
                      onChanged: (value) => _checkPasswordsMatch(),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        // Shows a check or error icon based on password match status
                        suffixIcon: _passwordsMatch
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 32),
                    // Reset password button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _passwordsMatch
                            ? () {
                                // Shows a snackbar message and navigates back on successful reset
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Password changed successfully!')),
                                );
                                Navigator.pop(
                                    context); // Navigates back to the login page (bir önceki sayfaya döndürüyor)
                              }
                            : null, // Disabled if passwords don't match
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reset Password'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Back to login button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context); // Navigates back to the login page (bir önceki sayfaya döndürüyor.)
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
