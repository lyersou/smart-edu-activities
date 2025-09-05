import 'dart:convert';
import 'package:http/http.dart' as http;

import '../screens/TestPage.dart';

class ApiService {
  final String baseUrl = "http://172.20.10.2:8081/recommandation/monapi"; // Local server URL

  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final url = Uri.parse(
        '$baseUrl/utilisateur/se-connecter?nom_utilisateur=$username&mot_passe=$password');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        // Parse the response as JSON and extract the result and userId
        Map<String, dynamic> data = json.decode(response.body);
        return data; // Return the parsed data (result and userId)
      } catch (e) {
        throw Exception('Error parsing response: $e');
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  // Register user
  Future<bool> registerUser(String username, String email, String password, String sex) async {
    final url = Uri.parse('$baseUrl/utilisateur/s-enregistrer');

    final Map<String, String> userData = {
      'nom_utilisateur': username,
      'email': email,
      'mot_passe': password,
      'sexe': sex, // ✅ Must match backend field
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 409) {
        // Username and password combo already exists
        throw Exception('Username and password already exist');
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to register');
    }
  }

  // Assuming you're using the correct API to fetch user data by ID
  Future<Map<String, dynamic>> fetchUserProfile(int userId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/utilisateur/getUtilisateur/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Fetch course data based on user ID
  Future<List<Map<String, dynamic>>> fetchCours(int userId) async {
    final url = Uri.parse('$baseUrl/utilisateur/cours/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return {
          'idCour': item['idCour'],
          'nomCour': item['nomCour'],
          'scoreRequis': item['scoreRequis'],
          'nomNiveau': item['nomNiveau'], // Add level name here
          'icon': item['icon'], // Include the icon as well
        };
      }).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserHistory(int userId) async {
    final url = Uri.parse('$baseUrl/utilisateur/historique-utilisateur/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // Debug: Print the raw API response
      print('Raw User History Response: $jsonData');

      return List<Map<String, dynamic>>.from(jsonData.map((item) {
        // Ensure 'timestamp' is either valid or 'N/A' if not available
        final timestamp = item['timestamp'] ?? 'N/A';

        return {
          'idRess': item['idRess'], // ✅ Added idRess here
          'nomRess': item['nomRess'] ?? 'Unknown Resource',
          'timestamp': timestamp,
          'type': item['type'] ?? 'Unknown Type',
        };
      }));
    } else {
      throw Exception('Failed to load user history');
    }
  }

  Future<List<Map<String, dynamic>>> fetchContentByType({
    required String contentType,
    required String userId,
    int? courseId,
  }) async {
    final url = Uri.parse('$baseUrl/utilisateur/ressources/$userId/${courseId ?? ''}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> resources = json.decode(response.body);

      // Debug: Print the raw API response
      print('Raw API response for resources: $resources');

      // Iterate over the resources and ensure each resource has an id_ress
      return resources
          .where((resource) => resource['type'] == contentType)
          .map((e) {
        final resourceMap = Map<String, dynamic>.from(e);

        // Debug: Print resource data for inspection
        print('Resource: $resourceMap');

        // Check if 'id_ress' exists and is not null
        final idRess = resourceMap['idRess'] ?? 'N/A';  // Default to 'N/A' if missing

        // Debug: Print id_ress to check
        print('idRess: $idRess');

        // Return the resource with a validated id_ress
        return {
          ...resourceMap,
          'idRess': idRess,  // Ensure id_ress is included in the response
        };
      }).toList();
    } else {
      throw Exception('Failed to load resources');
    }
  }

  // MOVED FROM ContentResource: Fetch content based on type, userId, and courseId
  Future<List<dynamic>> fetchContent(String contentType, String userId, int? courseId) async {
    final url = Uri.parse('$baseUrl/utilisateur/ressources/$userId/$courseId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> resources = json.decode(response.body);
      return resources.where((resource) => resource['type'] == contentType).toList();
    } else {
      throw Exception('Failed to load resources');
    }
  }

  // Fetch recommendations based on userId
  Future<List<String>> fetchRecommendations(String userId) async {
    final url = Uri.parse('$baseUrl/utilisateur/recommandation/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      List<String> contentTypes = [];

      // Loop through the response and add content type to list
      for (var resource in data) {
        String type = resource['type'];
        if (!contentTypes.contains(type)) {
          contentTypes.add(type); // Avoid duplicates
        }
      }

      return contentTypes; // Return list of content types (Video, Audio, Text)
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  // Update user data
  Future<void> updateUser(Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/utilisateur/mettre-a-jour-utilisateur'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // NEW METHOD: Fetch passed courses
  Future<List<int>> fetchPassedCourses(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/utilisateur/userPassedCourses/$userId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> passedCourses = data['passedCourses'];

        // Debug: Print the raw passed courses data
        print('Raw Passed Courses Response: $passedCourses');

        return passedCourses.map<int>((course) => course as int).toList();
      } else {
        print('Failed to load passed courses. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return []; // Return empty list instead of throwing exception
      }
    } catch (e) {
      print('Exception while fetching passed courses: $e');
      return []; // Return empty list on error
    }
  }

  // Fetch recommended tests based on userId and courseId
  Future<List<Test>> fetchRecommendedTests(String userId, int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/utilisateur/recomtest/$userId/$courseId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((test) => Test.fromJson(test)).toList();
      } else {
        throw Exception('Failed to load recommended tests');
      }
    } catch (e) {
      throw Exception('Failed to load recommended tests: $e');
    }
  }

  // Save test result to the backend
  Future<bool> saveTestResult({
    required int idUtilisateur,
    required int idTest,
    required bool nbrPassage,
    required int valeurObtenue,
    required String evaluation,
    required DateTime datePassage,
  }) async {
    final url = Uri.parse('$baseUrl/utilisateur/saveTestResult');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "idUtilisateur": idUtilisateur,
        "idTest": idTest,
        "nbrPassage": nbrPassage,
        "valeurObtenue": valeurObtenue,
        "evaluation": evaluation,
        "datePassage": datePassage.toIso8601String(),
      }),
    );

    print("🔁 Status Code: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    return response.statusCode == 200;
  }


  // Fetch similar content from the API
  Future<List<dynamic>> fetchSimilarContent(String contentType, String userId, int? courseId) async {
    final url = Uri.parse('$baseUrl/utilisateur/similar/$userId/$courseId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> resources = json.decode(response.body);
      return resources
          .where((resource) => resource['type'] == contentType)
          .toList();
    } else {
      throw Exception('Failed to load similar content');
    }
  }

  // MOVED FROM ContentResource: Fetch the favorite status of the resource from the backend
  Future<bool> fetchFavoriteStatus(String userId, int resourceId) async {
    final url = Uri.parse('$baseUrl/utilisateur/favoris_status/$userId/$resourceId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['isFavorite'] ?? false;
    } else {
      throw Exception('Failed to fetch favorite status');
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(String userId, int resourceId) async {
    final url = Uri.parse('$baseUrl/utilisateur/favoris_ajouter');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_utilisateur': int.parse(userId),
        'id_ress': resourceId,
        'date_ajout': DateTime.now().toIso8601String().split('T')[0],
      }),
    );

    return response.statusCode == 201;
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String userId, int resourceId) async {
    final url = Uri.parse('$baseUrl/utilisateur/favoris_supprimer');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_utilisateur': int.parse(userId),
        'id_ress': resourceId,
      }),
    );

    return response.statusCode == 200;
  }

  // Save resource interaction history to backend
  Future<bool> saveHistory({
    required String userId,
    required int resourceId,
    required bool cliqueCable,
    required int timeSpent,
  }) async {
    final url = Uri.parse('$baseUrl/utilisateur/save_history');

    final Map<String, dynamic> historyData = {
      "idUtilisateur": int.parse(userId), // ensure it's sent as int
      "idRess": resourceId,
      "cliqueCable": cliqueCable,
      "timeSpent": timeSpent,
    };

    print("Sending history data: $historyData");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(historyData),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print('✅ History saved successfully');
        return true;
      } else {
        print('❌ Failed to save history: ${response.body}');
        return false;
      }
    } catch (e) {
      print("❌ Exception while sending history: $e");
      return false;
    }
  }

  // MOVED FROM FavPage: Fetch user's favorites by user ID
  Future<List<dynamic>> fetchFavorites(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/utilisateur/favoris/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load favorites: ${response.body}');
    }
  }

  // MOVED FROM EditlevelPage: Update user's level
  Future<void> updateLevel(int idUtilisateur, int idNiveau) async {
    final response = await http.put(
      Uri.parse('$baseUrl/utilisateur/mettre-a-jour-niveau'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id_utilisateur': idUtilisateur,
        'id_niveau': idNiveau,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update level: ${response.body}');
    }
  }
}