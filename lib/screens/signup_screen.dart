import 'package:flutter/material.dart';
import 'package:myapp/screens/signup_Success.dart';
import 'package:myapp/services/api_service.dart';

import '../main.dart';

  class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _selectedSex;
  String? _errorMessage; // Error message variable

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  final Map<String, String> sexOptions = {
    "Male": "male",
    "Female": "female",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF6880BC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF323B60), size: 30),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  (route) => false, // This clears the entire navigation stack
            );
          },

        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/log.png', height: 30),
            SizedBox(width: 5),
            Text(
              "My First ABC",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Feather',
                color: Color(0xFF323B60),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF323B60),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextField("Username", Icons.person, _usernameController),
                  SizedBox(height: 10),
                  buildTextField("Email Address", Icons.email, _emailController),
                  SizedBox(height: 10),
                  buildTextField("Password", Icons.lock, _passwordController, obscureText: true),
                  SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      prefixIcon: Icon(Icons.wc, color: Color(0xFF323B60)),
                    ),
                    value: _selectedSex,
                    hint: Text("Select Sex"),
                    items: sexOptions.keys.map((sex) {
                      return DropdownMenuItem(
                        value: sex,
                        child: Text(sex),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSex = value;
                      });
                    },
                  ),
                  SizedBox(height: 5),
                  // Display error message if there is any
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (_usernameController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          _selectedSex != null) {
                        try {
                          bool success = await _apiService.registerUser(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                            sexOptions[_selectedSex!]!, // Send backend value
                          );

                          if (success) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginSuccessScreen()),
                            );
                          } else {
                            setState(() {
                              _errorMessage = "Registration failed. Please try again.";
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _errorMessage = "Username and password already exist.";
                          });
                        }
                      } else {
                        setState(() {
                          _errorMessage = "Please fill in all fields.";
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6880BC),
                      padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, IconData icon, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Color(0xFF323B60)),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}