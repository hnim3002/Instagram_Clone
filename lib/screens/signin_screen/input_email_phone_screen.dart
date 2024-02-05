import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clon/screens/signin_screen/input_password_fullname.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../Widgets/CustomDivider_widgets.dart';
import '../../Widgets/CustomButton_widgets.dart';
import '../../Widgets/InputTextField_widgets.dart';
import '../login_screen.dart';

class InputEmailScreen extends StatefulWidget {
  final String username;
  const InputEmailScreen({super.key, required this.username});

  @override
  State<InputEmailScreen> createState() => _InputEmailScreenState();
}

class _InputEmailScreenState extends State<InputEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {

    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Column(
                children: [
                  Flexible(flex: 1, child: Container(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(
                    height: 170.0,
                    child: Image.asset("assets/images/ic_user.png"),
                  ),
                  TabBar(
                    indicator: null,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: isDarkMode ? Colors.white : Colors.black,
                    isScrollable: false,
                    tabs: const [
                      Tab(
                        text: 'PHONE',
                      ),
                      Tab(text: 'EMAIL'),
                    ],
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Content for Tab 1
                        PhoneNumberTabContent(
                          isDarkMode: isDarkMode,
                          username: widget.username,
                        ),

                        // Content for Tab 2\
                        EmailTabContent(
                            username: widget.username,
                            isDarkMode: isDarkMode,
                            emailController: _emailController)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(),
            ),
            const CustomDivider(),
            SmallTextButton(
              isDarkMode: isDarkMode,
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              firText: "Already have an account? ",
              secText: "Log in.",
            ),
            const SizedBox(
              height: 15.0,
            )
          ],
        )),
      ),
    );
  }
}

class EmailTabContent extends StatelessWidget {
  const EmailTabContent({
    super.key,
    required this.isDarkMode,
    required TextEditingController emailController,
    required this.username,
  }) : _emailController = emailController;

  final String username;
  final bool isDarkMode;
  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15.0,
        ),
        InputTextField(
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
          borderSideColor: isDarkMode ? Colors.black : Colors.grey.shade400,
          hintText: "Email",
          textInputType: TextInputType.emailAddress,
          textEditingController: _emailController,
          isPassword: false,
        ),
        const SizedBox(
          height: 15.0,
        ),
        CustomButton(
          buttonContext: const Text(
            "Next",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InputPasswordScreen(
                          username: username,
                          emailPhone: _emailController.text.trim(),
                        )));
          },
        ),
      ],
    );
  }
}

class PhoneNumberTabContent extends StatelessWidget {
  const PhoneNumberTabContent({
    super.key,
    required this.isDarkMode,
    required this.username,
  });

  final String username;
  final bool isDarkMode;
  final String number = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15.0,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: isDarkMode ? Colors.black : Colors.grey.shade400,
            ),
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              number = number.phoneNumber.toString() as PhoneNumber;
              print(number.phoneNumber);
            },
            onInputValidated: (bool value) {
              // Validate phone number
              print(value);
            },
            selectorConfig: const SelectorConfig(
              showFlags: false,
              selectorType: PhoneInputSelectorType.DIALOG,
              useEmoji: false,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: TextStyle(
                fontFamily: "Roboto",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
            inputDecoration: InputDecoration(
              hintText: "Phone",
              hintStyle: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.withOpacity(1)),
              border: InputBorder.none,
            ),
            inputBorder: OutlineInputBorder(
                borderSide: Divider.createBorderSide(context)),
          ),
        ),
        const SizedBox(
          height: 17.0,
        ),
        Text(
          "You may receive SMS notifications from us for security and login purposes.",
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 15.0,
        ),
        CustomButton(
          buttonContext: const Text(
            "Next",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InputPasswordScreen(
                        username: username, emailPhone: number)));
          },
        ),
      ],
    );
  }
}

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  PhoneNumberTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
        prefixIcon: Icon(Icons.phone),
      ),
    );
  }
}
