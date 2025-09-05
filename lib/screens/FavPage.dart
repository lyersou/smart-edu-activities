import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the ApiService

class FavPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const FavPage({Key? key, required this.userData}) : super(key: key);

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  late Future<List<dynamic>> _favoritesFuture;
  final ApiService _apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _apiService.fetchFavorites(widget.userData['id_utilisateur']);
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "Unknown date";
    DateTime parsedDate = DateTime.parse(dateString);
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
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
              'Favorites',
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
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No favorites found.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            } else {
              final favorites = snapshot.data!;
              return ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final fav = favorites[index];
                  final formattedDate = formatDate(fav['date_ajout']);

                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF323B60), width: 2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.favorite, color: Color(
                          0xFFEF0202), size: 32),
                      title: Text(
                        fav['nomRess'] ?? 'Unknown Resource',
                        style: const TextStyle(
                          color: Color(0xFF323B60),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fav['type'] ?? 'Unknown Type',
                            style: const TextStyle(
                              color: Color(0xFFFFA500),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}