import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FullScreenPdfPage extends StatelessWidget {
  final String filePath;

  const FullScreenPdfPage({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalPages = 0;
    int currentPage = 0;
    PDFViewController? pdfViewController;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the default back button
        backgroundColor: const Color(0xFF6880BC), // Set background color
        elevation: 0, // Remove the default elevation/shadow
        title: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context), // Navigate back when tapped
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF323B60), // Color for the back icon
                size: 30, // Set size for the back icon
              ),
            ),
            const SizedBox(width: 17), // Space between the back icon and the title
            // Title Text
            const Text(
              'PDF Viewer',
              style: TextStyle(
                fontSize: 17, // Font size for the title
                fontWeight: FontWeight.bold, // Bold font weight
                fontFamily: 'Feather', // Custom font family (if available)
                color: Color(0xFF323B60), // Set text color
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: PDFView(
              filePath: filePath,
              swipeHorizontal: true,
              onRender: (pages) {
                totalPages = pages!;
              },
              onViewCreated: (controller) {
                pdfViewController = controller;
              },
              onPageChanged: (page, _) {
                currentPage = page ?? 0;
              },
              onError: (error) {
                print("PDF error: $error");
              },
              onPageError: (page, error) {
                print("PDF page error: $error on page $page");
              },
            ),
          ),
        ],
      ),
    );
  }
}
