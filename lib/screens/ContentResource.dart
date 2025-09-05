import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'ResourceDetailPage.dart';

class ContentResource extends StatelessWidget {
  final String contentType;
  final String userId;
  final int? courseId;
  final ApiService apiService = ApiService(); // Create instance of ApiService

  ContentResource({
    Key? key,
    required this.contentType,
    required this.userId,
    this.courseId,
  }) : super(key: key);

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
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF323B60),
                size: 30,
              ),
            ),
            const SizedBox(width: 17),
            Text(
              contentType,
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
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchContent(contentType, userId, courseId), // Use ApiService method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No content available',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Feather',
                  color: Color(0xFF323B60),
                ),
              ),
            );
          } else {
            final resources = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: resources.length * 2 + 1, // Add 1 for SizedBox before and after cards
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SizedBox(height: 7); // Adjust height as needed
                } else if (index.isOdd) {
                  return const SizedBox(height: 5); // Adjust height as needed
                } else {
                  final resource = resources[(index - 1) ~/ 2];
                  return _buildContentCard(context, resource);
                }
              },
            );
          }
        },
      ),
    );
  }

  // Build each content card and handle navigation
  Widget _buildContentCard(BuildContext context, dynamic resource) {
    IconData iconData;

    switch (resource['type']) {
      case 'Video':
        iconData = Icons.play_circle_fill;
        break;
      case 'Audio':
        iconData = Icons.audiotrack;
        break;
      case 'Text':
        iconData = Icons.text_fields;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return FutureBuilder<bool>(
          future: apiService.fetchFavoriteStatus(userId, resource['idRess']), // Use ApiService method
          builder: (context, favoriteSnapshot) {
            if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (favoriteSnapshot.hasError) {
              return Center(
                child: Text('Error: ${favoriteSnapshot.error ?? 'Unknown error'}'),
              );
            } else if (!favoriteSnapshot.hasData) {
              return const Center(child: Text('Failed to fetch favorite status.'));
            } else {
              bool isFavorite = favoriteSnapshot.data ?? false;

              return SizedBox(
                width: double.infinity,
                height: 150,
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF323B60), width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          color: const Color(0xFFFFA500),
                          size: 40,
                        ),
                      ],
                    ),
                    title: Text(
                      resource['nomRess'] ?? 'Unknown Resource',
                      style: const TextStyle(fontSize: 15, color: Color(0xFF323B60)),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        resource['type'] ?? 'Unknown Type',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () async {
                        if (isFavorite) {
                          // Remove from favorites using ApiService
                          bool success = await apiService.removeFromFavorites(userId, resource['idRess']);
                          if (success) {
                            setState(() {
                              isFavorite = false;
                            });
                          }
                        } else {
                          // Add to favorites using ApiService
                          bool success = await apiService.addToFavorites(userId, resource['idRess']);
                          if (success) {
                            setState(() {
                              isFavorite = true;
                            });
                          }
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResourceDetailPage(
                            contentType: contentType,  // Pass contentType
                            userId: userId,            // Pass userId
                            courseId: courseId,        // Pass courseId
                            resource: resource,        // Pass the resource
                            startTime: DateTime.now(), // Passing current time as start time
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}