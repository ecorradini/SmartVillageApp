import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//ignore: must_be_immutable
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
    toolbarHeight: small ? 20 : 100.0,
    flexibleSpace: Container(),
    automaticallyImplyLeading: false,
    backgroundColor: background,
  );
}