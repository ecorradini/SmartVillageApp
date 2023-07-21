import 'package:flutter/material.dart';

class SmartVillageButton extends StatefulWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final bool loading;
  final bool big;

  const SmartVillageButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.textColor,
    this.loading = false,
    this.big = false
  }) : super(key: key);

  @override
  SmartVillageButtonState createState() => SmartVillageButtonState();
}

class SmartVillageButtonState extends State<SmartVillageButton> {
  double _buttonWidth = double.infinity;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _buttonWidth,
      height: widget.big ? 55 : 40,
      child: ElevatedButton(
        onPressed: widget.loading ? null : widget.onPressed,
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
        onLongPress: widget.onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.loading)
              SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                  strokeWidth: 2.0,
                ),
              ),
            Text(
              widget.text,
              style: TextStyle(fontSize: 18, color: widget.textColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(SmartVillageButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) {
      setState(() {
        _buttonWidth = widget.loading ? 36.0 : double.infinity;
      });
    }
  }
}