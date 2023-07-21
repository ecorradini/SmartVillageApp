import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmartVillageAppBar extends AppBar {
  SmartVillageAppBar({Key? key, String? title, Color background=CupertinoColors.white}) : super(
    key: key,
    title: Text(
      title ?? "Smart Village",
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.start,
    ),
    centerTitle: false,
    elevation: 0,
    toolbarHeight: 100.0,
    flexibleSpace: Container(),
    automaticallyImplyLeading: false,
    backgroundColor: background,
  );
}