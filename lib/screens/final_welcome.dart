import 'package:flutter/material.dart';
import 'dart:async';
import 'finalmain_page.dart';

class FinalWelcomeScreen extends StatefulWidget {
  @override
  _FinalWelcomeScreenState createState() => _FinalWelcomeScreenState();
}

class _FinalWelcomeScreenState extends State<FinalWelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  String fullText = "You are ready to start learning !";
  String displayedText = "";
  int textIndex = 0;
  bool textCompleted = false;
  bool showAnimation = false;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start Typing Animation
    _startTypingEffect();
  }

  void _startTypingEffect() {
    int durationPerCharacter = (2000 ~/ fullText.length);
    Timer.periodic(Duration(milliseconds: durationPerCharacter), (timer) {
      if (textIndex < fullText.length) {
        setState(() {
          displayedText += fullText[textIndex];
          textIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          textCompleted = true;
          _startBounceAnimation();
        });
      }
    });
  }

  void _startBounceAnimation() {
    setState(() {
      showAnimation = true;
    });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF6880BC), size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 105),

              // Chat Bubble Positioned Above Character
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, showAnimation ? -_bounceAnimation.value : 0),
                    child: child,
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Chat Bubble
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Color(0xFF6880BC), width: 2),
                      ),
                      child: Text(
                        displayedText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF323B60),
                        ),
                      ),
                    ),

                    // Arrow pointing DOWN to the character
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -10, // Moves arrow below the bubble
                      child: Align(
                        alignment: Alignment.center,
                        child: CustomPaint(
                          size: Size(20, 10),
                          painter: ChatBubbleArrowPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 0),

              // Character Image Below the Bubble
              Center(
                child: Image.asset('assets/rabbit.png', height: 150),
              ),
              SizedBox(height: 168),

              // "Start Learning" Button
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: textCompleted
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FinalMainPage(userId: '',)),
                      );
                    }
                        : null, // Disable button until text is completed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textCompleted ? Color(0xFF6880BC) : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'START LEARNING',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Paint for Chat Bubble Arrow
class ChatBubbleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFF6880BC);

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
