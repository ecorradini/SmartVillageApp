import 'package:flutter/material.dart';

class SmartVillageAppBar extends AppBar {
  SmartVillageAppBar({Key? key, String title="Smart Village"}) : super(
    key: key,
    title: Align(
      alignment: Alignment.bottomLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.start,
      ),
    ),
    centerTitle: false,
    elevation: 0,
  );
}