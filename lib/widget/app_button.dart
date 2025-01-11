
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {Key? key,
        required this.action,
        required this.buttonText,
        required this.buttonBackground,
        required this.textColor,
        this.splashColor})
      : super(key: key);

  final Function()? action;
  final String buttonText;
  final Color buttonBackground;
  final Color textColor;
  final Color? splashColor;

  @override
  Widget build(BuildContext context) {
    // Button splash color
    Color buttonSplashColor = splashColor ?? buttonBackground;
    // Return button component
    return TextButton(
      onPressed: action,
      style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: WidgetStatePropertyAll(buttonSplashColor)),
      child: Container(
        alignment: Alignment.center,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: buttonBackground,
        ),
        child: Text(buttonText,
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ),
    );
  }
}