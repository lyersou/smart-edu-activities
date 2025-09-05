import 'package:flutter/material.dart';
import 'liste_habbite.dart';
import 'dart:async';

class AgePage extends StatefulWidget {
  final int progressStep;

  AgePage({required this.progressStep});

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<AgePage> with SingleTickerProviderStateMixin {
  String? selectedAgeGroup;
  bool showMainTitle = false;
  bool showOptions = false;
  bool showButton = false;
  List<bool> showEachOption = [false, false];

  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  String fullText = "Select your age group to start learning!";
  String displayedText = "";
  int textIndex = 0;
  bool textCompleted = false;
  bool showAnimation = false;

  @override
  void initState() {
    super.initState();

    // Initialize bounce animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 500));
    _startTypingEffect();

    await Future.delayed(Duration(milliseconds: 1200));
    setState(() => showMainTitle = true);

    await Future.delayed(Duration(milliseconds: 60));
    setState(() => showOptions = true);

    for (int i = 0; i < showEachOption.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() => showEachOption[i] = true);
    }

    await Future.delayed(Duration(milliseconds: 100));
    setState(() => showButton = true);
  }

  void _startTypingEffect() {
    int durationPerCharacter = (900 ~/ fullText.length);
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

  void _goToNextPage() {
    if (selectedAgeGroup != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListeHabitsPage(progressStep: widget.progressStep + 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF323B60), size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildProgressBar(widget.progressStep), // Centered Progress Bar
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // Image & Speech Bubble
              Row(
                children: [
                  Image.asset("assets/rabbit.png", height: 70, width: 70),
                  SizedBox(width: 10),
                  AnimatedOpacity(
                    opacity: displayedText.isNotEmpty ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 600),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, showAnimation ? _bounceAnimation.value : 0),
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Color(0xFF6880BC), width: 2),
                              ),
                              child: Text(
                                displayedText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF323B60)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Section Title
              AnimatedOpacity(
                opacity: showMainTitle ? 1.0 : 0.0,
                duration: Duration(milliseconds: 600),
                child: Text(
                  "Select Your Age Group",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF323B60)),
                ),
              ),

              SizedBox(height: 20),

              // Age Group Options
              Column(
                children: [
                  _animatedOptionTile("Ages 3-6", Icons.child_care, 0),
                  _animatedOptionTile("Ages 6-12", Icons.school, 1),
                ],
              ),

              SizedBox(height: 20),

              // Continue Button
              AnimatedOpacity(
                opacity: showButton ? 1.0 : 0.0,
                duration: Duration(milliseconds: 600),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: selectedAgeGroup != null ? _goToNextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAgeGroup != null ? Color(0xFF6880BC) : Colors.grey.shade300,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text("Next", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Progress Bar Widget (Centered)
  Widget _buildProgressBar(int step) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 70,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: index < step ? Color(0xFF6880BC) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // Animated Option Tiles
  Widget _animatedOptionTile(String option, IconData icon, int index) {
    return AnimatedOpacity(
      opacity: showEachOption[index] ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => setState(() {
          if (selectedAgeGroup == option) {
            selectedAgeGroup = null;
          } else {
            selectedAgeGroup = option;
          }
        }),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: selectedAgeGroup == option ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selectedAgeGroup == option ? Color(0xFF6880BC) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFF323B60), size: 24),
              SizedBox(width: 10),
              Text(
                option,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF323B60)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
