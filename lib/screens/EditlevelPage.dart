import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the ApiService

class EditlevelPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditlevelPage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditlevelPageState createState() => _EditlevelPageState();
}

class _EditlevelPageState extends State<EditlevelPage> {
  final _formKey = GlobalKey<FormState>();
  int selectedLevel = 1;
  String? successMessage;
  final ApiService _apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.userData['id_niveau'] ?? 1;
  }

  Future<void> updateLevel() async {
    try {
      await _apiService.updateLevel(
        widget.userData['id_utilisateur'],
        selectedLevel,
      );

      setState(() {
        successMessage = "Level updated successfully";
      });
    } catch (e) {
      setState(() {
        successMessage = 'Error: $e';
      });
    }
  }

  void _submitForm() async {
    updateLevel();
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
              'Change Level',
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 70),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Edit Level',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF323B60),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.extension, color: Color(0xFFFFA500),size: 30,),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Update your current level',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // LEVEL Dropdown styled in Card
              Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: DropdownButtonFormField<int>(
                  value: selectedLevel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    prefixIcon: Icon(Icons.bar_chart, color: Color(0xFF323B60)),
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text('Beginner')),
                    DropdownMenuItem(value: 2, child: Text('Intermediate')),
                    DropdownMenuItem(value: 3, child: Text('Advanced')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value!;
                    });
                  },
                ),
              ),

              if (successMessage != null) ...[
                SizedBox(height: 20),
                Text(
                  successMessage!,
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6880BC),
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                ),
                child: Text(
                  'Update Level',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}