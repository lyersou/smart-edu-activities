import 'package:flutter/material.dart';
import 'ContentResource.dart';
import 'dart:math' as math;

class ResourcesPage extends StatefulWidget {
  final String userId;
  final int courseId;

  const ResourcesPage({Key? key, required this.userId, required this.courseId}) : super(key: key);

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> with TickerProviderStateMixin {
  // Animation controllers for each icon
  late AnimationController _videoAnimationController;
  late AnimationController _audioAnimationController;
  late AnimationController _textAnimationController;

  // Scale animations for hover effect
  late Animation<double> _videoScaleAnimation;
  late Animation<double> _audioScaleAnimation;
  late Animation<double> _textScaleAnimation;

  // Jump animations
  late Animation<double> _videoJumpAnimation;
  late Animation<double> _audioJumpAnimation;
  late Animation<double> _textJumpAnimation;

  // Rotation animations
  late Animation<double> _videoRotationAnimation;
  late Animation<double> _audioRotationAnimation;
  late Animation<double> _textRotationAnimation;

  @override
  void initState() {
    super.initState();

    // Video animation (bouncy effect)
    _videoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _videoJumpAnimation = TweenSequence<double>([
      // First jump up
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 15.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // First bounce down
      TweenSequenceItem(
        tween: Tween<double>(begin: 15.0, end: 5.0)
            .chain(CurveTween(curve: Curves.bounceIn)),
        weight: 15.0,
      ),
      // Small second jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Land again with tiny bounce
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 30.0,
      ),
      // Rest before next cycle
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_videoAnimationController);

    _videoScaleAnimation = TweenSequence<double>([
      // Stretch when jumping up
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // Squish when landing first time
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10.0,
      ),
      // Return to normal for second jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Final landing squish
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 15.0,
      ),
      // Return to normal with slight wobble
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20.0,
      ),
      // Rest at normal size
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 20.0,
      ),
    ]).animate(_videoAnimationController);

    _videoRotationAnimation = TweenSequence<double>([
      // Tilt one way when jumping
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // Tilt the other way when landing
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
      // Return to normal
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20.0,
      ),
      // Rest with no rotation
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_videoAnimationController);

    // Audio animation - exactly like video animation
    _audioAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _audioJumpAnimation = TweenSequence<double>([
      // First jump up
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 15.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // First bounce down
      TweenSequenceItem(
        tween: Tween<double>(begin: 15.0, end: 5.0)
            .chain(CurveTween(curve: Curves.bounceIn)),
        weight: 15.0,
      ),
      // Small second jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Land again with tiny bounce
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 30.0,
      ),
      // Rest before next cycle
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_audioAnimationController);

    _audioScaleAnimation = TweenSequence<double>([
      // Stretch when jumping up
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // Squish when landing first time
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10.0,
      ),
      // Return to normal for second jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Final landing squish
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 15.0,
      ),
      // Return to normal with slight wobble
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20.0,
      ),
      // Rest at normal size
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 20.0,
      ),
    ]).animate(_audioAnimationController);

    _audioRotationAnimation = TweenSequence<double>([
      // Tilt one way when jumping
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // Tilt the other way when landing
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
      // Return to normal
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20.0,
      ),
      // Rest with no rotation
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_audioAnimationController);

    // Text animation - exactly like video animation
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _textJumpAnimation = TweenSequence<double>([
      // First jump up
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 15.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // First bounce down
      TweenSequenceItem(
        tween: Tween<double>(begin: 15.0, end: 5.0)
            .chain(CurveTween(curve: Curves.bounceIn)),
        weight: 15.0,
      ),
      // Small second jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Land again with tiny bounce
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 30.0,
      ),
      // Rest before next cycle
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_textAnimationController);

    _textScaleAnimation = TweenSequence<double>([
      // Stretch when jumping up
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // Squish when landing first time
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10.0,
      ),
      // Return to normal for second jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Final landing squish
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 15.0,
      ),
      // Return to normal with slight wobble
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20.0,
      ),
      // Rest at normal size
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 20.0,
      ),
    ]).animate(_textAnimationController);

    _textRotationAnimation = TweenSequence<double>([
      // Tilt one way when jumping
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      // Tilt the other way when landing
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
      // Return to normal
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20.0,
      ),
      // Rest with no rotation
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_textAnimationController);
  }

  @override
  void dispose() {
    _videoAnimationController.dispose();
    _audioAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Resources',
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
      body: ListView(
        padding: const EdgeInsets.all(6.0),
        children: [
          const SizedBox(height: 20),
          _buildAnimatedResourceCard(
            context,
            icon: Icons.ondemand_video,
            label: 'Video Content',
            subtitle: 'Explore video lessons and improve your skills!',
            type: 'Video',
            animationController: _videoAnimationController,
            jumpAnimation: _videoJumpAnimation,
            scaleAnimation: _videoScaleAnimation,
            rotationAnimation: _videoRotationAnimation,
          ),
          _buildAnimatedResourceCard(
            context,
              icon: Icons.headset,
            label: 'Audio Content',
            subtitle: 'Listen to audio resources to enhance your learning!',
            type: 'Audio',
            animationController: _audioAnimationController,
            jumpAnimation: _audioJumpAnimation,
            scaleAnimation: _audioScaleAnimation,
            rotationAnimation: _audioRotationAnimation,
          ),
          _buildAnimatedResourceCard(
            context,
            icon: Icons.description,
            label: 'Text Content',
            subtitle: 'Read text-based resources for your improvement!',
            type: 'Text',
            animationController: _textAnimationController,
            jumpAnimation: _textJumpAnimation,
            scaleAnimation: _textScaleAnimation,
            rotationAnimation: _textRotationAnimation,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedResourceCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String subtitle,
        required String type,
        required AnimationController animationController,
        required Animation<double> jumpAnimation,
        required Animation<double> scaleAnimation,
        required Animation<double> rotationAnimation,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentResource(
              contentType: type,
              userId: widget.userId,
              courseId: widget.courseId,
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF323B60), width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.white,
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
                          offset: Offset(0, -jumpAnimation.value),
                          child: Transform.rotate(
                            angle: rotationAnimation.value,
                            child: Transform.scale(
                              scale: scaleAnimation.value,
                              child: Icon(icon, color: const Color(0xFFFFA500), size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF323B60),
                              ),
                            ),
                          ],
                        ),
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
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}