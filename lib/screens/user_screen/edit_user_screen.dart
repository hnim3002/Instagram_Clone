import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit profile",
          style: TextStyle(
              letterSpacing: 0.5,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),

      ),
      body: SafeArea(
        child: Column(

        ),
      ),
    );
  }
}
