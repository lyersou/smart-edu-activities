import 'package:flutter/material.dart';
import 'dart:async';

import 'final_welcome.dart';

class ListeHabitsPage extends StatefulWidget {
  final int progressStep;

  ListeHabitsPage({required this.progressStep});

  @override
  _ListeHabitsPageState createState() => _ListeHabitsPageState();
}

class _ListeHabitsPageState extends State<ListeHabitsPage>
    with SingleTickerProviderStateMixin {
  Set<String> selectedHabits = {}; // Multi-selection enabled
  bool showMainTitle = false;
  bool showOptions = false;
  bool showButton = false;
  List<bool> showEachOption = [false, false, false, false, false];

  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  String fullText = "Which habit do you enjoy the most?";
  String displayedText = "";
  int textIndex = 0;
  bool textCompleted = false;
  bool showAnimation = false;

  @override
  void initState() {
    super.initState();

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
    if (selectedHabits.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalWelcomeScreen(),
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
          icon: Icon(Icons.arrow_back, color: Color(0xFF6880BC), size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildProgressBar(widget.progressStep),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

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
                  "Select Your Favorite Habits",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF323B60)),
                ),
              ),

              SizedBox(height: 20),

              // Habit Selection List
              Column(
                children: [
                  _animatedOptionTile("Reading", Icons.menu_book, 0),
                  _animatedOptionTile("Writing", Icons.edit, 1),
                  _animatedOptionTile("Sports Activities", Icons.sports_soccer, 2),
                  _animatedOptionTile("Listening", Icons.headphones, 3),
                  _animatedOptionTile("Creativity", Icons.brush, 4),
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
                    onPressed: selectedHabits.isNotEmpty ? _goToNextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedHabits.isNotEmpty ? Color(0xFF6880BC) : Colors.grey.shade300,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text("NEXT", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Progress Bar Widget
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

  // Animated Habit Tiles (Multi-selection enabled)
  Widget _animatedOptionTile(String habit, IconData icon, int index) {
    return AnimatedOpacity(
      opacity: showEachOption[index] ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => setState(() {
          if (selectedHabits.contains(habit)) {
            selectedHabits.remove(habit);
          } else {
            selectedHabits.add(habit);
          }
        }),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: selectedHabits.contains(habit) ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selectedHabits.contains(habit) ? Color(0xFF6880BC) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFF323B60), size: 24),
              SizedBox(width: 10),
              Text(
                habit,
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
