import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clon/screens/signin_screen/input_username_screen.dart';

import 'package:instagram_clon/utils/color_schemes.dart';

import '../Widgets/CustomButton_widgets.dart';
import '../Widgets/InputTextField_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Container(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SvgPicture.asset(
                    "assets/images/ic_instagram.svg",
                    colorFilter: ColorFilter.mode(
                        isDarkMode ? primaryColor : Colors.black,
                        BlendMode.srcIn),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InputTextField(
                    fillColor:
                        isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
                    borderSideColor:
                        isDarkMode ? Colors.black : Colors.grey.shade400,
                    hintText: "Phone number, email or username",
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                    isPassword: false,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  InputTextField(
                    fillColor:
                        isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
                    borderSideColor:
                        isDarkMode ? Colors.black : Colors.grey.shade400,
                    hintText: "Password",
                    textInputType: TextInputType.visiblePassword,
                    textEditingController: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 17.0,
                  ),
                  CustomButton(
                    buttonContext: const Text(
                      "Log in",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(
                    height: 9.0,
                  ),
                  SmallTextButton(
                    isDarkMode: isDarkMode,
                    onPressed: () {},
                    firText: "Forgot your login details? ",
                    secText: "Get help logging in.",
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: CustomDivider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        child: CustomDivider(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  CustomButton(
                    buttonContext: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/images/ic_facebook.svg",
                          colorFilter: const ColorFilter.mode(
                              primaryColor, BlendMode.srcIn),
                        ),
                        const SizedBox(
                            width:
                                8.0), // Adjust the spacing between icon and text
                        const Text(
                          'Logging in with Facebook',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(),
            ),
            const CustomDivider(),
            SmallTextButton(
              isDarkMode: isDarkMode,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InputUserNameScreen()));
              },
              firText: "Don't have an account? ",
              secText: "Sign up.",
            ),
            const SizedBox(
              height: 15.0,
            )
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
            onPressed();
            print("a");
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
            onPressed();
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
