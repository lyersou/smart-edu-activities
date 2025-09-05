import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ContentResource.dart';
import 'ContentRecommand.dart';

  class RecommandPage extends StatefulWidget {
  final String userId;
  final int courseId; // courseId passed from previous page

  const RecommandPage({Key? key, required this.userId, required this.courseId}) : super(key: key);

  @override
  _RecommandPageState createState() => _RecommandPageState();
}

class _RecommandPageState extends State<RecommandPage> {
  late Future<List<String>> recommendations;

  @override
  void initState() {
    super.initState();
    recommendations = ApiService().fetchRecommendations(widget.userId); // Fetch recommendations based on userId
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
              'Recommended Resources',
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
      body: FutureBuilder<List<String>>(
        future: recommendations, // Use the recommendations future to build UI
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<String> contentTypes = snapshot.data!;

            List<Widget> resourceCards = [];

// Add spacing before the first card only if there is at least one type
            bool addedFirstSpacing = false;

            if (contentTypes.contains('Video')) {
              if (!addedFirstSpacing) {
                resourceCards.add(const SizedBox(height: 20));
                addedFirstSpacing = true;
              }
              resourceCards.add(
                _buildResourceCard(
                  context,
                  icon: Icons.play_circle_fill,
                  label: 'Video Content',
                  subtitle: 'Explore video lessons and improve your skills!',
                  type: 'Video',
                ),
              );
            }
            if (contentTypes.contains('Audio')) {
              if (!addedFirstSpacing) {
                resourceCards.add(const SizedBox(height: 20));
                addedFirstSpacing = true;
              }
              resourceCards.add(
                _buildResourceCard(
                  context,
                  icon: Icons.audiotrack,
                  label: 'Audio Content',
                  subtitle: 'Listen to audio resources to enhance your learning!',
                  type: 'Audio',
                ),
              );
            }
            if (contentTypes.contains('Text')) {
              if (!addedFirstSpacing) {
                resourceCards.add(const SizedBox(height: 20));
                addedFirstSpacing = true;
              }
              resourceCards.add(
                _buildResourceCard(
                  context,
                  icon: Icons.text_fields,
                  label: 'Text Content',
                  subtitle: 'Read text-based resources for your improvement!',
                  type: 'Text',
                ),
              );
            }


            return ListView(
              padding: const EdgeInsets.all(6.0),
              children: resourceCards,
            );
          }
          else {
            return const Center(
              child: Text(
                'No recommendations available',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Feather',
                  color: Color(0xFF323B60),  // Customize this color as per your design
                ),
              ),
            );
          }

        },
      ),
    );
  }

  Widget _buildResourceCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String subtitle,
        required String type,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentRecommand(
              contentType: type,
              userId: widget.userId,
              courseId: widget.courseId, // Pass courseId here
            ),
          ),
        );
      },
      child: Card(
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
                  Icon(icon, color: const Color(0xFFFFA500), size: 40),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 40),
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
      ),
    );
  }
}
