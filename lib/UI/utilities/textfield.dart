import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartvillage/UI/utilities/rounded_container.dart';

class SmartVillageTextField extends CupertinoTextField {
  SmartVillageTextField({
    Key? key,
    required BuildContext context,
    String? placeholder,
    TextEditingController? controller,
    bool? borderless,
    TextInputType? keyboardType,
    bool? obscureText
  }) : super(
    key: key,
    controller: controller,
    keyboardType: keyboardType,
    autocorrect: false,
    maxLines: 1,
    placeholder: placeholder,
    obscureText: obscureText ?? false,
    style: const TextStyle(fontSize: 17),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: borderless ?? false ? null : Border.all(
        color: Theme.of(context).colorScheme.background,
        width: 1.0,
      ),
      color: Theme.of(context).colorScheme.surface,
    ),
    padding: const EdgeInsets.all(12),
    scrollPadding: const EdgeInsets.only(bottom: 40),
    placeholderStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
  );
}

class SmartVillageTextFieldWithIcon extends StatelessWidget {
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String placeholder;
  final bool obscureText;
  final BuildContext context;
  const SmartVillageTextFieldWithIcon({
    super.key,
    required this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.placeholder = "",
    this.obscureText = false,
    required this.context
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      paddings: false,
        widgets: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: SmartVillageTextField(
                  context: context,
                  controller: controller,
                  keyboardType: keyboardType,
                  placeholder: placeholder,
                  borderless: true,
                  obscureText: obscureText,
                ),
              )
            ],
          ),
        ]
    );
  }
}
