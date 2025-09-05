  import 'package:flutter/material.dart';
  import 'dart:math' as math;
  import 'RecommandPage.dart';
  import 'ResourcesPage.dart';
  import 'TestPage.dart';

  class LetterDetailPage extends StatefulWidget {
    final String letter;
    final String word;
    final String userId;
    final int courseId;

    const LetterDetailPage({
      Key? key,
      required this.letter,
      required this.word,
      required this.userId,
      required this.courseId,
    }) : super(key: key);

    @override
    State<LetterDetailPage> createState() => _LetterDetailPageState();
  }

  class _LetterDetailPageState extends State<LetterDetailPage> with TickerProviderStateMixin {
    // Animation controllers for each icon
    late AnimationController _bookAnimationController;
    late AnimationController _settingsAnimationController;
    late AnimationController _gameAnimationController;

    // Scale animations for hover effect
    late Animation<double> _bookScaleAnimation;
    late Animation<double> _settingsScaleAnimation;
    late Animation<double> _gameScaleAnimation;

    // Rotation animations
    late Animation<double> _settingsRotationAnimation;
    late Animation<double> _gameRotationAnimation; // New rotation animation for game icon

    // Float animations for book icon
    late Animation<double> _bookFloatAnimation;

    // Jump animations for game icon
    late Animation<double> _gameJumpAnimation;

    @override
    void initState() {
      super.initState();

      // Book animation (floating effect)
      _bookAnimationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true);

      _bookFloatAnimation = Tween<double>(
        begin: 0.0,
        end: 10.0,
      ).animate(CurvedAnimation(
        parent: _bookAnimationController,
        curve: Curves.easeInOut,
      ));

      _bookScaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _bookAnimationController,
        curve: Curves.easeInOut,
      ));

      // Settings animation (rotation effect)
      _settingsAnimationController = AnimationController(
        duration: const Duration(seconds: 5),
        vsync: this,
      )..repeat();

      _settingsRotationAnimation = Tween<double>(
        begin: 0.0,
        end: 2 * math.pi,
      ).animate(_settingsAnimationController);

      _settingsScaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _settingsAnimationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ));

      // Game animation (fun, bouncy effect)
      _gameAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      )..repeat();

  // Create a more playful jumping sequence with multiple bounces
      _gameJumpAnimation = TweenSequence<double>([
        // First jump up
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 20.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20.0,
        ),
        // First bounce down
        TweenSequenceItem(
          tween: Tween<double>(begin: 20.0, end: 5.0)
              .chain(CurveTween(curve: Curves.bounceIn)),
          weight: 15.0,
        ),
        // Small second jump
        TweenSequenceItem(
          tween: Tween<double>(begin: 5.0, end: 12.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 15.0,
        ),
        // Land again with tiny bounce
        TweenSequenceItem(
          tween: Tween<double>(begin: 12.0, end: 0.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 30.0,
        ),
        // Rest before next cycle
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 0.0),
          weight: 20.0,
        ),
      ]).animate(_gameAnimationController);

  // Fun scale and rotation animations
      _gameScaleAnimation = TweenSequence<double>([
        // Stretch when jumping up
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20.0,
        ),
        // Squish when landing first time
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 0.85)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 10.0,
        ),
        // Return to normal for second jump
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.85, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 15.0,
        ),
        // Final landing squish
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 0.9)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 15.0,
        ),
        // Return to normal with slight wobble
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 20.0,
        ),
        // Rest at normal size
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0),
          weight: 20.0,
        ),
      ]).animate(_gameAnimationController);

  // Add slight rotation animation for more playfulness
      _gameRotationAnimation = TweenSequence<double>([
        // Tilt one way when jumping
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 0.1)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20.0,
        ),
        // Tilt the other way when landing
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.1, end: -0.1)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40.0,
        ),
        // Return to normal
        TweenSequenceItem(
          tween: Tween<double>(begin: -0.1, end: 0.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 20.0,
        ),
        // Rest with no rotation
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 0.0),
          weight: 20.0,
        ),
      ]).animate(_gameAnimationController);
    }

    @override
    void dispose() {
      _bookAnimationController.dispose();
      _settingsAnimationController.dispose();
      _gameAnimationController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      int coursePositionInLevel;
      if (widget.courseId >= 1 && widget.courseId <= 26) {
        coursePositionInLevel = widget.courseId;
      } else if (widget.courseId >= 27 && widget.courseId <= 52) {
        coursePositionInLevel = widget.courseId - 26;
      } else if (widget.courseId >= 53 && widget.courseId <= 78) {
        coursePositionInLevel = widget.courseId - 52;
      } else {
        coursePositionInLevel = 0;
      }

      bool isRecommendationUnlocked = coursePositionInLevel >= 6;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF6880BC),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Color(0xFF323B60), size: 30),
              ),
              const SizedBox(width: 17),
              Text(
                widget.letter,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Feather',
                  color: Color(0xFF323B60),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAnimatedBookCard(
                context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResourcesPage(
                        userId: widget.userId,
                        courseId: widget.courseId,
                      ),
                    ),
                  );
                },
                enabled: true,
                showLockDesign: false,
              ),
              _buildAnimatedSettingsCard(
                context,
                subtitle: isRecommendationUnlocked
                    ? 'Recommended based on your progress!'
                    : 'Reach course 5 in this level to unlock!',
                onTap: () {
                  if (isRecommendationUnlocked) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommandPage(
                          userId: widget.userId,
                          courseId: widget.courseId,
                        ),
                      ),
                    );
                  }
                },
                enabled: isRecommendationUnlocked,
                showLockDesign: true,
              ),
              _buildAnimatedGameCard(
                context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendedTestsPage(
                        userId: widget.userId.toString(),
                        courseId: widget.courseId,
                      ),
                    ),
                  );
                },
                enabled: true,
                showLockDesign: false,
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildAnimatedBookCard(
        BuildContext context, {
          required VoidCallback onTap,
          required bool enabled,
          required bool showLockDesign,
        }) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedBuilder(
          animation: _bookAnimationController,
          builder: (context, child) {
            return Stack(
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF323B60), width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: enabled ? Colors.white : Colors.grey[300],
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: Transform.translate(
                                offset: Offset(0, -_bookFloatAnimation.value),
                                child: Transform.scale(
                                  scale: _bookScaleAnimation.value,
                                  child: Icon(
                                    Icons.emoji_objects,
                                    color: enabled ? const Color(0xFFFFA500) : Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'More details about the letter',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF323B60),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 72),
                          child: Text(
                            'Fun facts and useful tips about this letter!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    Widget _buildAnimatedSettingsCard(
        BuildContext context, {
          required String subtitle,
          required VoidCallback onTap,
          required bool enabled,
          required bool showLockDesign,
        }) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedBuilder(
          animation: _settingsAnimationController,
          builder: (context, child) {
            return Stack(
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF323B60), width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: enabled ? Colors.white : Colors.grey[300],
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: Transform.scale(
                                scale: _settingsScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _settingsRotationAnimation.value,
                                  child: Icon(
                                    Icons.settings,
                                    color: enabled ? const Color(0xFFFFA500) : Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Recommendation',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF323B60),
                                ),
                              ),
                            ),
                            if (showLockDesign)
                              Icon(
                                enabled ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                color: const Color(0xFFFFA500),
                                size: 28,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 72),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: enabled ? Colors.grey[700] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showLockDesign && !enabled)
                  const Positioned(
                    top: 8,
                    left: 12,
                    child: Icon(
                      Icons.lock,
                      color: Color(0xFFFFA500),
                      size: 24,
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    Widget _buildAnimatedGameCard(
        BuildContext context, {
          required VoidCallback onTap,
          required bool enabled,
          required bool showLockDesign,
        }) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedBuilder(
          animation: _gameAnimationController,
          builder: (context, child) {
            return Stack(
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF323B60), width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: enabled ? Colors.white : Colors.grey[300],
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: Transform.translate(
                                offset: Offset(0, -_gameJumpAnimation.value),
                                child: Transform.rotate(
                                  angle: _gameRotationAnimation.value,
                                  child: Transform.scale(
                                    scale: _gameScaleAnimation.value,
                                    child: Icon(
                                      Icons.sports_esports,
                                      color: enabled ? const Color(0xFFFFA500) : Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Take a Test',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF323B60),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  enabled
                                      ? Text(
                                    "Let's play and learn!",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 72),
                          child: Text(
                            'Let\'s see what you\'ve learned!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }