import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmartVillageButton extends StatefulWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final bool big;
  final bool enabled;

  const SmartVillageButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.textColor,
    this.big = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  SmartVillageButtonState createState() => SmartVillageButtonState();
}

class SmartVillageButtonState extends State<SmartVillageButton> {
  double _buttonWidth = double.infinity;

  @override
  Widget build(BuildContext context) {
    if(widget.enabled) {
      return SizedBox(
        width: _buttonWidth,
        height: widget.big ? 55 : 40,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(widget.color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide.none,
              ),
            ),
            elevation: MaterialStateProperty.all<double>(0),
          ),
          child: AutoSizeText(
            widget.text,
            style: TextStyle(color: widget.textColor),
            maxLines: 1,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(CupertinoColors.inactiveGray),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide.none,
            ),
          ),
          elevation: MaterialStateProperty.all<double>(0),
        ),
        onLongPress: null,
        child: AutoSizeText(
          widget.text,
          style: const TextStyle(color: CupertinoColors.white),
          maxLines: 1
        ),
      );
    }
  }
}