import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class FullScreenVideoPage extends StatefulWidget {
  final VideoPlayerController videoController;

  const FullScreenVideoPage({Key? key, required this.videoController}) : super(key: key);

  @override
  _FullScreenVideoPageState createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  bool _isInitialized = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    if (!widget.videoController.value.isInitialized) {
      widget.videoController.initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        widget.videoController.play(); // Start playing the video
      });
    } else {
      setState(() {
        _isInitialized = true;
      });
      widget.videoController.play(); // Start playing the video if already initialized
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Unlock orientation when leaving full screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? GestureDetector(
        onTap: () {
          setState(() {
            // Toggle play/pause when screen is tapped
            if (_isPaused) {
              widget.videoController.play();
            } else {
              widget.videoController.pause();
            }
            _isPaused = !_isPaused;
          });
        },
        child: Stack(
          children: [
            // Ensure the video fills the entire screen without leaning to one side
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover, // Ensures the video fills the screen while maintaining the aspect ratio
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: VideoPlayer(widget.videoController),
                ),
              ),
            ),
            // Back arrow in the top left
            Positioned(
              top: 40, // Adjust the position if needed
              left: 20, // Adjust the position if needed
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Go back to the previous page
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            // Optionally, show a play/pause overlay icon when paused
            if (_isPaused)
              Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 60,
                ),
              ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()), // Loading indicator if not initialized
    );
  }
}
