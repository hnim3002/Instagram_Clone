import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/utils/utils.dart';

import '../../Widgets/CustomButton_widgets.dart';
import '../../Widgets/InputTextField_widgets.dart';
import '../Home_screen.dart';

class InputPasswordScreen extends StatefulWidget {
  final String username;
  final String emailPhone;
  const InputPasswordScreen(
      {super.key, required this.username, required this.emailPhone});

  @override
  State<InputPasswordScreen> createState() => _InputPasswordScreenState();
}

class _InputPasswordScreenState extends State<InputPasswordScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRePasswordCheck = false;
  bool _isLoading = false;

  @override
  void dispose() {

    super.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
  }

  Future<void> signUp() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
        email: widget.emailPhone,
        password: _passwordController.text.trim(),
        username: widget.username,
        fullname: _fullNameController.text.trim());
    setState(() {
      _isLoading = false;
    });
    if (res == "success") {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      });
    } else {
      if (!mounted) return;
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(
              height: 80.0,
            ),
            const Text(
              "NAME AND PASSWORD",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15.0,
            ),
            InputTextField(
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
              borderSideColor: isDarkMode ? Colors.black : Colors.grey.shade400,
              hintText: "Full name",
              textInputType: TextInputType.emailAddress,
              textEditingController: _fullNameController,
              isPassword: false,
            ),
            const SizedBox(
              height: 15.0,
            ),
            InputTextField(
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
              borderSideColor: isDarkMode ? Colors.black : Colors.grey.shade400,
              hintText: "Password",
              textInputType: TextInputType.visiblePassword,
              textEditingController: _passwordController,
              isPassword: true,
            ),
            Row(
              children: [
                Checkbox(
                    value: isRePasswordCheck,
                    onChanged: (checkBoxValue) {
                      setState(() {
                        isRePasswordCheck = checkBoxValue!;
                      });
                    },
                    side: BorderSide(color: Colors.grey.shade600, width: 2.0)),
                Text(
                  "Remember password",
                  style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600),
                )
              ],
            ),
            CustomButton(
              buttonContext: _isLoading
                  ? const SizedBox(
                      width: 20.0, // Set the desired width
                      height: 20.0, // Set the desired height
                      child: CircularProgressIndicator(strokeWidth: 3.0),
                    )
                  : const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
              onPressed: () {
                signUp();
              },
            ),
            Flexible(
              flex: 1,
              child: Container(),
            ),
            Text(
              "Your contacts will be periodically synced and stored on Instagram servers "
              "to help you and others find friends, and to help us provide a better "
              "service. To remove contacts, go to Settings and disconnect.",
              style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40.0,
            )
          ],
        ),
      )),
    );
  }
}
