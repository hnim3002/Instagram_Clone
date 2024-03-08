import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';

class ChatListScreen extends StatefulWidget {
  final Function closeBtnOnPressed;
  const ChatListScreen({super.key, required this.closeBtnOnPressed});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.closeBtnOnPressed();
          },
        ),
        title:Text(
          user!.username!,
          style: const TextStyle(
              letterSpacing: 0.5,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: const <Widget>[
            Text('Chat List'),
          ],
        ),
      ),
    );
  }
}
