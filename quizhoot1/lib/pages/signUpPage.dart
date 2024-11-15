import 'package:flutter/material.dart';
import 'package:quizhoot/pages/loginPage.dart'; // Import the next page after sign up
import 'package:sign_in_button/sign_in_button.dart'; // Import the Google sign-in button
import '../services/auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();

  // Controllers for the text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isChecked = false; // To manage the checkbox (Privacy Policy acceptance)
  bool _obscureText = true; // To manage the visibility of the password field

  void _register() async {
    // Simple validation check
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must accept the Privacy Policy and Terms of Use')),
      );
      return;
    }

    try {
      final response = await _authService.register(
        _firstNameController.text,
        _lastNameController.text,
        _usernameController.text,
        _emailController.text,
        _phoneNumberController.text,
        _passwordController.text
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // Get screen height
    double width = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Set background color
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05), // Horizontal padding based on screen width
        child: SingleChildScrollView(
          // Enable vertical scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align elements to the start
            children: [
              SizedBox(height: height * 0.05), // Space at the top

              // App title
              Text(
                'Quizhoot',
                style: TextStyle(
                  fontSize: width * 0.09, // Font size based on screen width
                  fontWeight: FontWeight.w800, // Bold font weight
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
              const SizedBox(height: 40), // Space between title and form

              // First and Last Name Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTextField(_firstNameController, 'First Name', 'First Name'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_lastNameController, 'Last Name', 'Last Name'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Username input
              _buildTextField(_usernameController, 'Username', 'Username'),
              const SizedBox(height: 16),

              // Email input
              _buildTextField(_emailController, 'Email', 'Email'),
              const SizedBox(height: 16),

              // Phone Number input
              _buildTextField(_phoneNumberController, 'Phone Number', 'Phone Number'),
              const SizedBox(height: 16),

              // Password input
              _buildPasswordField(),
              const SizedBox(height: 32), // Space after password field

              // Privacy Policy and Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!; // Update checkbox value
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I accept the Privacy Policy and Terms of Use',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              // Sign Up Button
              SizedBox(
                width: double.infinity, // Full width button
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Create Account'),
                ),
              ),
              const SizedBox(height: 16), // Space between buttons

              // Google sign-in button
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1, // Full width button
                  height: 44, // Set height
                  child: SignInButton(
                    Buttons.google,
                    text: "Sign up with Google",
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text input fields
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint, // Hint text to guide the user
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  // Helper function to build password input field
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscureText, // Hide the password by default
      decoration: InputDecoration(
        hintText: 'Password', // Hint text for password
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility, // Toggle icon based on password visibility
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText; // Toggle password visibility
            });
          },
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
