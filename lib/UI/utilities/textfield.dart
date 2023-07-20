import 'package:flutter/cupertino.dart';

class SmartVillageTextField extends CupertinoTextField {
  SmartVillageTextField({
    Key? key,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool? obscureText
  }) : super(
    key: key,
    controller: controller,
    keyboardType: keyboardType,
    autocorrect: false,
    maxLines: 1,
    obscureText: obscureText ?? false,
    style: const TextStyle(fontSize: 17),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: CupertinoColors.lightBackgroundGray,
        width: 1.0,
      ),
      color: CupertinoColors.white,
    ),
    padding: const EdgeInsets.all(12),
    scrollPadding: const EdgeInsets.only(bottom:40)
  );
}
