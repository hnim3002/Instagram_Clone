import 'package:flutter/material.dart';

class SubSearchScreen extends StatefulWidget {
  const SubSearchScreen({super.key});

  @override
  State<SubSearchScreen> createState() => _SubSearchScreenState();
}

class _SubSearchScreenState extends State<SubSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("sub")),
        ),
      ),
    );
  }
}
