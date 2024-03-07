import 'package:flutter/material.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/color_schemes.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';
import '../../utils/utils.dart';

class EditUserData extends StatefulWidget {
  final String label;
  final String text;
  const EditUserData({super.key, required this.label, required this.text});

  @override
  State<EditUserData> createState() => _EditUserDataState();
}

class _EditUserDataState extends State<EditUserData> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool isValidate = true;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.text);
    if(widget.label == 'Username') {
      isValidate = false;
    }
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _showDialog(BuildContext context, String uid, String data, String value) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.0, // Set the desired width
                  height: 20.0, // Set the desired height
                  child: CircularProgressIndicator(strokeWidth: 3.0),
                ),
                SizedBox(width: 10,),
                Text('Processing...'), // Processing text
              ],
            ),
          ),

        );
      },
    );

    await FirestoreMethods().updateUserInfo(uid, data, value);
    await refreshUser();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.pop(context);
  }

  Future<void> refreshUser() async {
    await Provider.of<UserProvider>(context, listen: false).refreshUser();
  }


  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(
          widget.label,
          style: const TextStyle(
              letterSpacing: 0.5,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: isValidate ? () {
              _showDialog(context, user!.uid!, widget.label, _controller.text.trim());
            } : null,
            color: isValidate ? blueBtnColor : Colors.grey,
            icon: const Icon(Icons.done)
          )
        ],

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) async {
                  if(widget.label == 'Username') {
                    bool isExit = await FirestoreMethods().checkUsernameExist(value);
                    if(!isExit) {
                      setState(() {
                        isValidate = true;
                      });
                    }
                    else {
                      setState(() {
                        isValidate = false;
                      });
                      if (!context.mounted) return;
                      showSnackBar("The username $value is not available", context);
                    }
                  }
                },
                focusNode: _focusNode,
                controller: _controller,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
