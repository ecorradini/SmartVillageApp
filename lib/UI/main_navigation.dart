import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smartvillage/UI/home_before.dart';

import 'configura.dart';

class MainNavigation extends StatefulWidget {
  final bool logged;
  const MainNavigation({super.key, required this.logged});

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
              if(widget.logged) const BottomNavigationBarItem(
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
                  if(!widget.logged) {
                    return const HomeBefore();
                  } else {
                    return Container();
                  }
                } else if (index==1) {
                  if(widget.logged) {
                    return Container();
                  } else {
                    return const Configura();
                  }
                } else {
                  return const Configura();
                }
              },
            );
          },
        )
      )
    );
  }
}