import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../services/api_service.dart';
import 'FullScreenPdfPage.dart';
import 'FullScreenVideoPage.dart';

class RecommandDetailPage extends StatefulWidget {
  final String contentType;
  final String userId;
  final int? courseId;
  final dynamic resource;
  final DateTime startTime;

  const RecommandDetailPage({
    Key? key,
    required this.contentType,
    required this.userId,
    this.courseId,
    required this.resource,
    required this.startTime,
  }) : super(key: key);

  @override
  _RecommandDetailPageState createState() => _RecommandDetailPageState();
}

class _RecommandDetailPageState extends State<RecommandDetailPage> {
  final ApiService _apiService = ApiService(); // Add ApiService instance

  late String? path;
  late String type;

  late VideoPlayerController _videoController;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  String textContent = '';
  String? localPdfPath;
  int totalPages = 0;
  int currentPage = 0;
  PDFViewController? _pdfViewController;

  DateTime? _endTime;
  bool _cliqueCable = false;
  late Timer _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    path = widget.resource['chemin'];
    type = widget.resource['type'];

    if (type == 'Video') {
      _videoController = VideoPlayerController.asset('assets/videos/$path')
        ..initialize().then((_) {
          setState(() {
            _totalDuration = _videoController.value.duration.inMilliseconds.toDouble();
          });
        });

      _videoController.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _videoController.value.position.inMilliseconds.toDouble();
          });
        }
      });
    } else if (type == 'Audio') {
      _audioPlayer.setSourceAsset('assets/audios/$path');
    } else if (type == 'Text') {
      if (path?.endsWith('.pdf') == true) {
        loadPdfContent();
      } else {
        loadTextContent();
      }
    }

    _startTimer();
  }

  Future<void> loadTextContent() async {
    try {
      final loadedText = await rootBundle.loadString('assets/texts/$path');
      setState(() {
        textContent = loadedText;
      });
    } catch (e) {
      print("Error loading text file: $e");
    }
  }

  Future<void> loadPdfContent() async {
    try {
      final byteData = await rootBundle.load('assets/texts/$path');
      final buffer = byteData.buffer;
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$path');

      if (!await file.exists()) {
        await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }

      setState(() {
        localPdfPath = file.path;
      });
    } catch (e) {
      print("Error loading PDF: $e");
    }
  }

  @override
  void dispose() {
    if (type == 'Video') _videoController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();

    _timer.cancel(); // Stop timer
    _endTime = DateTime.now();
    _cliqueCable = true;

    // Save updated history with end time and timeSpent
    _saveHistory(widget.resource, widget.startTime);
    super.dispose();
  }

  // Start the timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(widget.startTime);
      });
    });
  }

  // Updated to use ApiService instead of local implementation
  void _saveHistory(dynamic resource, DateTime startTime) {
    final resourceId = resource['idRess'] ?? 0;
    final userId = widget.userId;
    final timeSpentInSeconds = _duration.inSeconds;

    _apiService.saveHistory(
      userId: userId,
      resourceId: resourceId,
      cliqueCable: _cliqueCable,
      timeSpent: timeSpentInSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6880BC),
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Color(0xFF323B60), size: 30),
            ),
            const SizedBox(width: 17),
            const Text(
              'Recommendation Detail',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              resource['nomRess'] ?? 'Unknown Resource',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF323B60)),
            ),
            const SizedBox(height: 8),
            Text(resource['type'] ?? 'Unknown Type',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFA500))),
            const SizedBox(height: 16),

            // ---------------- VIDEO ----------------
            if (type == 'Video') ...[
              _videoController.value.isInitialized
                  ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _videoController.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: () {
                      setState(() {
                        _videoController.value.isPlaying
                            ? _videoController.pause()
                            : _videoController.play();
                      });
                    },
                  ),
                ],
              )
                  : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              if (_videoController.value.isInitialized)
                Column(
                  children: [
                    Slider(
                      value: _currentPosition,
                      min: 0.0,
                      max: _totalDuration,
                      activeColor: Color(0xFF6880BC),
                      inactiveColor: Colors.grey.shade300,
                      thumbColor: Color(0xFF6880BC),
                      onChanged: (double value) {
                        _videoController.seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                      style: const TextStyle(color: Color(0xFF323B60)),
                    ),
                  ],
                ),
              const SizedBox(height: 9),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenVideoPage(videoController: _videoController),
                    ),
                  );
                },
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                label: const Text(
                  "View Fullscreen",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6880BC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ]

            // ---------------- AUDIO ----------------
            else if (type == 'Audio') ...[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF323B60), // Dark blue
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await _audioPlayer.play(AssetSource('audios/$path'));
                      },
                    ),
                  ),
                ),
              ),
            ]

            // ---------------- TEXT ----------------
            else if (type == 'Text') ...[
                // Check if the path is a PDF and if the local path is not null
                if (path?.endsWith('.pdf') == true && localPdfPath != null) ...[
                  // PDF display in RecommandDetailPage
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5, // Initially occupy most of the screen
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      border: Border.all(color: Color(0xFF6880BC)), // Border color for the PDF container
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // Rounded corners for the clipped content
                      child: PDFView(
                        filePath: localPdfPath!, // Path to the PDF file
                        swipeHorizontal: true, // Horizontal swipe to change pages
                        onRender: (pages) => setState(() => totalPages = pages!),
                        onViewCreated: (vc) => _pdfViewController = vc,
                        onPageChanged: (page, _) => setState(() => currentPage = page ?? 0),
                        onError: (error) {
                          print("PDF error: $error");
                        },
                        onPageError: (page, error) {
                          print("PDF page error: $error on page $page");
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing between the PDF container and the button
                  // Fullscreen toggle button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenPdfPage(filePath: localPdfPath!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fullscreen, color: Colors.white), // Icon color
                    label: const Text(
                      "View Fullscreen",
                      style: TextStyle(color: Colors.white), // Text color for the button
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6880BC), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners for the button
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Padding for button content
                    ),
                  ),
                ]
                // If not a PDF, display text content
                else ...[
                  Text(
                    textContent,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF323B60), // Text color
                      fontWeight: FontWeight.w500, // Slightly bolder text for better readability
                    ),
                  ),
                ],
              ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}