import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smartvillage/UI/home_after.dart';
import 'package:smartvillage/UI/home_before.dart';
import 'package:smartvillage/UI/salute.dart';

import 'configura.dart';

class MainNavigation extends StatefulWidget {
  final Map<String,dynamic> initValues;
  const MainNavigation({super.key, required this.initValues});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
      top: false,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              if(widget.initValues["logged"] ?? false) const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart_fill),
                label: 'Salute',
              ),
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.gear_solid),
                label: 'Configura',
              )
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return CupertinoTabView(
              builder: (BuildContext context) {
                if(index==0) {
                  if(!widget.initValues["logged"]) {
                    return const HomeBefore();
                  } else {
                    return HomeAfter();
                  }
                } else if (index==1) {
                  if(widget.initValues["logged"] ?? false) {
                    return Salute();
                  } else {
                    return Configura(loggedFromTest: widget.initValues["loggedFromTest"], logged: widget.initValues["logged"],);
                  }
                } else {
                  return Configura(loggedFromTest: widget.initValues["loggedFromTest"], logged: widget.initValues["logged"],);
                }
              },
            );
          },
        )
      )
    );
  }
}