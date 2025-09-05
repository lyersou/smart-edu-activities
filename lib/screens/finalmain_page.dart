import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'EditProfilePage.dart';
import 'EditlevelPage.dart';
import 'FavPage.dart';
import 'LetterDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfileMenuCard.dart';
import 'ResourceDetailPage.dart';
import 'login.dart';
import 'package:intl/intl.dart'; // at the top



class FinalMainPage extends StatefulWidget {
  final String userId;

  const FinalMainPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FinalMainPageState createState() => _FinalMainPageState();
}

class _FinalMainPageState extends State<FinalMainPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> coursData = [];
  bool isLoading = true;
  String? error;

  // New state variables for course unlocking
  List<int> passedCourses = [];
  bool areCoursesLoaded = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchCoursData();
    _fetchPassedCourses(); // Fetch passed courses on init
  }

  Future<void> _fetchCoursData() async {
    try {
      final data = await _apiService.fetchCours(int.parse(widget.userId));
      setState(() {
        coursData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // New method to fetch passed courses
  Future<void> _fetchPassedCourses() async {
    try {
      final data = await _apiService.fetchPassedCourses(int.parse(widget.userId));
      setState(() {
        passedCourses = data;
        areCoursesLoaded = true;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        areCoursesLoaded = true;
      });
    }
  }

  Future<void> _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Log Out',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Feather',
              color: appBarTextColor,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
          actions: [

            TextButton(
              child: const Text(
                'No',
                style: TextStyle(
                  color: Color(0xFFFFA500),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Color(0xFFFFA500),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }


  static const Color appBarColor = Color(0xFF6880BC);
  static const Color bottomNavColor = Colors.white;
  static const Color selectedIconColor = Color(0xFFFFA500);
  static const Color unselectedIconColor = Color(0xFF323B60);
  static const Color selectionBoxColor = Colors.white;
  static const Color selectionBoxBorder = Color(0xFF323B60);
  static const Color appBarTextColor = Color(0xFF323B60);




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/rabbitt.png', height: 50),
          const SizedBox(width: 17),
          Text(
            'My first ABC',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Feather',
              color: appBarTextColor,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: selectionBoxBorder, width: 2),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0), // Move it slightly to the right
          child: IconButton(
            icon: const Icon(Icons.logout),
            color: Color(0xFFFFA500),
            iconSize: 30.0,
            onPressed: _logout,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildCoursesPage();
      case 1:
        return _buildCenteredText();
      case 2:
        return _buildUserHistoryPage();
      case 3:
        return _buildProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUserHistoryPage() {
    return Container(
      color: Colors.white,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _apiService.fetchUserHistory(int.parse(widget.userId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No history found',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Feather',
                  color: appBarTextColor,
                ),
              ),
            );
          } else {
            final historyData = snapshot.data!;

            // Step 1: Sort data by timestamp descending (latest first)
            historyData.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));

            // Step 2: Group and remove duplicates within the same day
            final Map<String, Map<String, Map<String, dynamic>>> groupedByDay = {};

            for (var item in historyData) {
              final timestamp = item['timestamp'] ?? '';
              final DateTime parsedDate = DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now();
              final String dayName = DateFormat.EEEE().format(parsedDate);

              groupedByDay.putIfAbsent(dayName, () => {});

              // Only insert if not already exist resource in same day
              if (!groupedByDay[dayName]!.containsKey(item['nomRess'])) {
                groupedByDay[dayName]![item['nomRess']] = item;
              }
            }

            final groupedKeys = groupedByDay.keys.toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Center(
                    child: Text(
                      'History',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Feather',
                        color: appBarTextColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedKeys.length,
                    itemBuilder: (context, index) {
                      final dayName = groupedKeys[index];
                      final items = groupedByDay[dayName]!.values.toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Day Header
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              dayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF323B60),
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          // History Items for that day
                          ...items.map((item) {
                            final DateTime parsedTimestamp = DateTime.tryParse(item['timestamp'] ?? '')?.toLocal() ?? DateTime.now();
                            final formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm').format(parsedTimestamp);

                            return Column(
                              children: [
                                Card(
                                  color: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Color(0xFF323B60), width: 2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      _getIconForType(item['type']),
                                      color: const Color(0xFFFFA500),
                                      size: 37,
                                    ),
                                    title: Text(
                                      item['nomRess'] ?? 'Unknown Resource',
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
                                          item['type'] ?? 'Unknown Type',
                                          style: const TextStyle(
                                            color: Color(0xFFFFA500),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedTimestamp,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            );


                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'video':
        return Icons.ondemand_video;
      case 'audio':
        return Icons.headset;
      case 'text':
        return Icons.description;
      default:
        return Icons.help_outline; // fallback if type is unknown
    }
  }

  // Updated method with course unlocking functionality
  Widget _buildCoursesPage() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Let\'s learn!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Feather',
              color: appBarTextColor,
            ),
          ),
          const SizedBox(height: 13),
          isLoading || !areCoursesLoaded
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : Expanded(
            child: GridView.builder(
              itemCount: coursData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final courseId = coursData[index]['idCour'];

                // Determine if the course is unlocked
                // First course is always unlocked
                // A course is unlocked if the previous course is in passedCourses
                final isFirstCourse = index == 0;
                final isPreviousPassed = index > 0 && passedCourses.contains(coursData[index-1]['idCour']);
                final isCurrentPassed = passedCourses.contains(courseId);
                final isUnlocked = isFirstCourse || isPreviousPassed || isCurrentPassed;

                return GestureDetector(
                  onTap: isUnlocked
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LetterDetailPage(
                          letter: coursData[index]['nomCour'],
                          word: coursData[index]['nomNiveau'].toString(),
                          userId: widget.userId,
                          courseId: courseId,
                        ),
                      ),
                    ).then((_) {
                      // Refresh passed courses when returning from letter detail
                      _fetchPassedCourses();
                    });
                  }
                      : () {
                    // Show message for locked courses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Complete previous course first!'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: _buildCourseCard(
                    coursData[index]['nomCour'],
                    coursData[index]['nomNiveau'].toString(),
                    coursData[index]['icon'],
                    isUnlocked,
                    isCurrentPassed,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Container(
      color: Colors.white,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _apiService.fetchUserProfile(int.parse(widget.userId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            final userData = snapshot.data!;
            final userName = userData['nom_utilisateur'] ?? 'User';

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Account Settings",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Feather',
                          color: Color(0xFF323B60), // or use appBarTextColor if preferred
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      'Welcome, $userName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Feather',
                        color: Color(0xFF323B60), // or use appBarTextColor if preferred
                      ),
                    ),
                    Text(
                      "Update your settings like profile edit, etc.",
                      style: TextStyle(
                        color: Colors.grey[700], // Dark grey color
                      ),
                    ),
                    const SizedBox(height: 17),

                    // Kid-friendly icons
                    ProfileMenuCard(
                        icon: Icons.child_care, // Kid-friendly profile icon
                        title: "Profile Information",
                        subTitle: "Change your account information",
                        press: () async {
                          final TextEditingController passwordController = TextEditingController();
                          String? errorMessage;

                          final bool? confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: Text(
                                      'Enter Password',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Feather',
                                        color: Color(0xFF323B60),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: passwordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            hintText: 'The password is 1234',
                                            errorText: errorMessage, // 👈 shows red text under the field
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Color(0xFFFFA500),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Confirm',
                                          style: TextStyle(
                                            color: Color(0xFFFFA500),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (passwordController.text == '1234') {
                                            Navigator.of(context).pop(true);
                                          } else {
                                            setState(() {
                                              errorMessage = 'Incorrect password';
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );

                          if (confirmed == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(userData: snapshot.data!),
                              ),
                            );
                          }
                        }

                    ),

                    ProfileMenuCard(
                      icon: Icons.extension, // Fun icon for level/education
                      title: "Change Level",
                      subTitle: "Update your current level",
                      press: () async {
                        final TextEditingController passwordController = TextEditingController();
                        String? errorMessage;

                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Text(
                                    'Enter Password',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Feather',
                                      color: Color(0xFF323B60),
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: passwordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: 'The password is 1234',
                                          errorText: errorMessage,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color(0xFFFFA500),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(
                                          color: Color(0xFFFFA500),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (passwordController.text == '1234') {
                                          Navigator.of(context).pop(true);
                                        } else {
                                          setState(() {
                                            errorMessage = 'Incorrect password';
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );

                        if (confirmed == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditlevelPage(userData: snapshot.data!),
                            ),
                          );
                        }
                      },
                    ),


                    ProfileMenuCard(
                      icon: Icons.favorite_border, // Cute heart icon for favorites
                      title: "Favorites",
                      subTitle: "View your favorite items",
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavPage(userData: snapshot.data!), // Pass user data to FavPage
                          ),
                        );
                      },
                    ),

                    ProfileMenuCard(
                      icon: Icons.show_chart, // Growth or progress chart icon
                      title: "Progress Report",
                      subTitle: "Track your progress",
                      press: () {},
                    ),

                  ],
                ),
              ),
            );

          }
        },
      ),
    );
  }

  // Updated to show locked/unlocked state and completion status
  Widget _buildCourseCard(String courseName, String courseLevel, String icon, bool isUnlocked, bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: selectionBoxBorder, width: 2),
        borderRadius: BorderRadius.circular(24),
        color: isUnlocked ? Colors.white : Colors.grey[200],
      ),
      child: Stack(
        children: [
          Center( // Center everything inside the card
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon.isNotEmpty
                    ? Image.asset(
                  'assets/icons/$icon',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  color: isUnlocked ? null : Colors.grey,
                )
                    : Icon(Icons.image, size: 50, color: isUnlocked ? null : Colors.grey),
                const SizedBox(height: 10),
                Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? selectedIconColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  courseLevel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUnlocked ? Colors.grey[700] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.lock,
                    size: 40,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          if (isCompleted)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
        ],
      )

    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9.5),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: selectionBoxBorder, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.notifications_active, 1),
          _buildNavItem(Icons.history, 2),
          _buildNavItem(Icons.child_care, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 59,
        height: 52,
        decoration: isSelected
            ? BoxDecoration(
          color: selectionBoxColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selectionBoxBorder, width: 2),
        )
            : null,
        child: Icon(
          icon,size: 28,
          color: isSelected ? selectedIconColor : unselectedIconColor,
        ),
      ),
    );
  }

  Widget _buildCenteredText() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Center(
            child: Text(
              'Notification',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Feather',
                color: appBarTextColor,
              ),
            ),
          ),
        ),
        // You can add more notification widgets here later
      ],
    );
  }
}