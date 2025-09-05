import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'finalmain_page.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check login status
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;  // Get the login status
    String? userId = prefs.getString('userId');  // Get the user ID

    await Future.delayed(Duration(seconds: 3)); // Splash screen duration (3 seconds)

    if (isLoggedIn && userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FinalMainPage(userId: userId)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,  // Background color for the splash screen
      body: Center(
        child: Text(
          'Welcome to My App!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
