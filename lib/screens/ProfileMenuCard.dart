import 'package:flutter/material.dart';

class ProfileMenuCard extends StatelessWidget {
  final String title, subTitle;
  final IconData icon;
  final VoidCallback press;

  const ProfileMenuCard({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF323B60), width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: InkWell(
        onTap: press,
        borderRadius: BorderRadius.circular(25),
        highlightColor: Colors.white, // Light grey when pressed
        splashColor: Colors.white,    // Ripple effect in medium grey
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Icon(icon, size: 35, color: Color(0xFFFFA500)), // Orange
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF323B60),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subTitle,
            style: const TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 19, color: Color(0xFF323B60)),
        ),
      ),
    );
  }
}
