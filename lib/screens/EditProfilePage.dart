import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the ApiService

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService(); // Create an instance of ApiService

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String selectedSexe = 'h';
  String selectedAge = '3-6';
  String? successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.userData['nom_utilisateur']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _passwordController = TextEditingController(text: widget.userData['mot_passe']);

    selectedSexe = widget.userData['sexe'] ?? 'h';
    selectedAge = widget.userData['age'] ?? '3-6';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = {
        'id_utilisateur': widget.userData['id_utilisateur'],
        'nom_utilisateur': _nameController.text,
        'email': _emailController.text,
        'mot_passe': _passwordController.text,
        'sexe': selectedSexe,
        'age': selectedAge,
      };

      try {
        await _apiService.updateUser(updatedUser);
        setState(() {
          successMessage = "Profile updated successfully";
        });
      } catch (e) {
        setState(() {
          successMessage = 'Error: $e';
        });
      }
    }
  }

  // Custom method for building text fields with style
  Widget buildTextField(String label, IconData icon, TextEditingController controller,
      {bool obscureText = false}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          prefixIcon: Icon(icon, color: Color(0xFF323B60)),
          hintText: label,
        ),
        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'Profile Information',
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

      body: Container(
        color: Colors.white, // 👈 Set the background color here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 70),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF323B60),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.child_care,
                            color: Color(0xFFFFA500),size: 30,
                          ),
                        ],
                      ),

                      SizedBox(height: 5),
                      Text(
                        'Update your information',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                buildTextField('Nom utilisateur', Icons.person, _nameController),
                SizedBox(height: 10),
                buildTextField('Email Address', Icons.email, _emailController),
                SizedBox(height: 10),
                buildTextField('Mot de passe', Icons.lock, _passwordController, obscureText: true),
                SizedBox(height: 14),

                // Sexe Dropdown
                Card(
                  color: Colors.grey[200], // 👈 Match card background too
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: DropdownButtonFormField<String>(
                    value: selectedSexe,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      prefixIcon: Icon(Icons.wc, color: Color(0xFF323B60)),
                    ),
                    items: [
                      DropdownMenuItem(value: 'h', child: Text('Male')),
                      DropdownMenuItem(value: 'f', child: Text('Female')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSexe = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 14),

                // Age Dropdown
                Card(
                  color: Colors.grey[200], // 👈 Match card background too
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: DropdownButtonFormField<String>(
                    value: selectedAge,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      prefixIcon: Icon(Icons.access_time, color: Color(0xFF323B60)),
                    ),
                    items: [
                      DropdownMenuItem(value: '3-6', child: Text('3-6 years')),
                      DropdownMenuItem(value: '6-12', child: Text('6-12 years')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedAge = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 5),

                if (successMessage != null) ...[
                  SizedBox(height: 12),
                  Text(
                    successMessage!,
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6880BC),
                    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}