import 'package:flutter/material.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).user;

    return user == null
        ? const Scaffold(
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            body: SafeArea(
                child: Center(
              child: Text(user.fullname.toString()),
            )),
          );
  }
}
