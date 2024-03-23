import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed, required this.buttonContext,
  });

  final Function onPressed;
  final Widget buttonContext;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        ),
        onPressed: () {
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13.0),
          alignment: Alignment.center,
          width: double.infinity,
          decoration: const ShapeDecoration(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)))),
          child: buttonContext
        ));
  }
}
