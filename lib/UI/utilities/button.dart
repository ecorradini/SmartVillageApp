import 'package:flutter/material.dart';

class SmartVillageButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final Icon? icon;

  const SmartVillageButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.textColor,
    this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide.none,
            ),
          ),
          elevation: MaterialStateProperty.all<double>(0),
        ),
        child: Text(text, style: TextStyle(fontSize: 18, color: textColor),),
      );
    }
    else {
      return ElevatedButton.icon(
        icon: icon!,
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide.none,
            ),
          ),
          elevation: MaterialStateProperty.all<double>(0),
        ),
        label: Text(text, style: TextStyle(fontSize: 18, color: textColor),),
      );
    }
  }
}