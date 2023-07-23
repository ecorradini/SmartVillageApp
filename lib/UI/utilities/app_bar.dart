import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmartVillageAppBar extends AppBar {
  SmartVillageAppBar({Key? key, String? title, Color background=CupertinoColors.white, required BuildContext context, bool small=false}) : super(
    key: key,
    title: Text(
      title ?? "Smart Village",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground
      ),
      textAlign: TextAlign.start,
    ),
    centerTitle: false,
    elevation: 0,
    toolbarHeight: small ? 15 : 100.0,
    flexibleSpace: Container(),
    automaticallyImplyLeading: false,
    backgroundColor: background,
  );
}