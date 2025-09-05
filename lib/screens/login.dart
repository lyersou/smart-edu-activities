    import 'package:flutter/material.dart';
  import 'package:myapp/screens/signup_screen.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import '../main.dart';
  import '../services/api_service.dart';
    import 'finalmain_page.dart'; // Import the FinalMainPage
    import 'package:flutter/gestures.dart';


    class LoginScreen extends StatefulWidget {
      @override
      _LoginScreenState createState() => _LoginScreenState();
    }

    class _LoginScreenState extends State<LoginScreen> {
      final TextEditingController _usernameController = TextEditingController();
      final TextEditingController _passwordController = TextEditingController();
      String? _errorMessage;
      ApiService apiService = ApiService(); // Create ApiService instance

      @override
      void initState() {
        super.initState();
        _checkLoginStatus();
      }

      // Check if user is logged in
      void _checkLoginStatus() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('is_logged_in') ?? false; // Default to false if not set

        if (isLoggedIn) {
          String? userId = prefs.getString('user_id');
          if (userId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FinalMainPage(userId: userId)),
            );
          }
        }
      }

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
            ),
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      Image.asset(
                        'assets/animal.png',
                        height: 90,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF323B60),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Login to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      buildTextField("Username", Icons.person, controller: _usernameController),
                      SizedBox(height: 10),
                      buildTextField("Password", Icons.lock, controller: _passwordController, obscureText: true),
                      SizedBox(height: 10),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6880BC),
                          padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      SizedBox(height: 15),
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Color(0xFF323B60)),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Color(0xFFFFA500),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                                  );
                                },
                            ),
                          ],
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

      // Build input fields for username and password
      Widget buildTextField(String hintText, IconData icon, {bool obscureText = false, TextEditingController? controller}) {
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

      // Handle login
      void _login() async {
        setState(() {
          _errorMessage = null;
        });

        final String username = _usernameController.text;
        final String password = _passwordController.text;

        if (username.isEmpty || password.isEmpty) {
          setState(() {
            _errorMessage = "Please enter both username and password.";
          });
          return;
        }

        try {
          // Use ApiService to validate the credentials
          Map<String, dynamic> result = await apiService.loginUser(username, password);

          if (result['result'] == 2) {
            String userId = result['userId']; // Get the user's ID

            // Save login status and user ID to SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('is_logged_in', true);
            prefs.setString('user_id', userId);

            // Success - navigate to the next screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FinalMainPage(userId: userId)), // Pass userId to the next screen
            );
          } else if (result['result'] == 1) {
            setState(() {
              _errorMessage = "Incorrect password. Please try again.";
            });
          } else {
            setState(() {
              _errorMessage = "User not found. Please sign up.";
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = "Error: $e";
          });
        }
      }
    }
