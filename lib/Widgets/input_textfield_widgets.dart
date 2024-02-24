import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    required this.fillColor,
    required this.borderSideColor,
    required this.hintText,
    required this.textInputType,
    required this.textEditingController,
    required this.isPassword,
  });

  final Color? fillColor;
  final Color borderSideColor;
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController textEditingController;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      controller: textEditingController,
      keyboardType: textInputType,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              fontFamily: "Roboto",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.withOpacity(1)),
          border:
              OutlineInputBorder(borderSide: Divider.createBorderSide(context)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderSideColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderSideColor),
          ),
          fillColor: fillColor,
          filled: true,
          contentPadding: const EdgeInsets.all(8.0)),
    );
  }
}
