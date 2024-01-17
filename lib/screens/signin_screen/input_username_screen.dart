import 'package:flutter/material.dart';
import 'package:instagram_clon/screens/signin_screen/input_email_phone_screen.dart';

import '../../Widgets/CustomButton_widgets.dart';
import '../../Widgets/InputTextField_widgets.dart';

class InputUserNameScreen extends StatefulWidget {
  const InputUserNameScreen({super.key});

  @override
  State<InputUserNameScreen> createState() => _InputUserNameScreenState();
}

class _InputUserNameScreenState extends State<InputUserNameScreen> {
  final TextEditingController _userNameController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _userNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    "Choose username",
                    style: TextStyle(fontSize: 25.0),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "You can always change it later",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InputTextField(
                    fillColor:
                        isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
                    borderSideColor:
                        isDarkMode ? Colors.black : Colors.grey.shade400,
                    hintText: "Username",
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _userNameController,
                    isPassword: false,
                  ),
                  const SizedBox(
                    height: 17.0,
                  ),
                  CustomButton(
                    buttonContext: const Text(
                      "Next",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InputEmailScreen()));
                    },
                  ),
                  const SizedBox(
                    height: 9.0,
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey[400]?.withOpacity(0.4),
      height: 20,
    );
  }
}

class SmallTextButton extends StatelessWidget {
  const SmallTextButton({
    super.key,
    required this.isDarkMode,
    required this.onPressed,
    required this.firText,
    required this.secText,
  });

  final bool isDarkMode;
  final Function onPressed;
  final String firText;
  final String secText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            onPressed;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              firText,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12.0, letterSpacing: 0.1),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressed;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              secText,
              style: TextStyle(
                  fontFamily: 'Roboto',
                  color: isDarkMode ? Colors.white : Colors.purple.shade900,
                  fontSize: 12.0,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
