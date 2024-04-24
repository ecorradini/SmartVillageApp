import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smartvillage/UI/home_after.dart';
import 'package:smartvillage/UI/home_before.dart';
import 'package:smartvillage/UI/salute.dart';

import '../API/health/health_manager.dart';
import '../API/mosaico/mosaico_user.dart';
import 'configura.dart';

//ignore: must_be_immutable
class MainNavigation extends StatefulWidget {
  Map<String,dynamic> initValues;
  MainNavigation({super.key, required this.initValues});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {

  late MosaicoUser mosaicoUser;
  HealthManager? healthManager;

  @override
  void initState() {
    mosaicoUser = widget.initValues["mosaicoUser"]!;
    healthManager = widget.initValues["healthManager"]!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
      top: false,
        bottom: false,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              if(mosaicoUser.isLogged()) const BottomNavigationBarItem(
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
                  if(!mosaicoUser.isLogged()) {
                    return HomeBefore(mosaicoUserManager: widget.initValues["mosaicoUserManager"]!, mosaicoUser: mosaicoUser,);
                  } else {
                    return HomeAfter(user: mosaicoUser,);
                  }
                } else if (index==1) {
                  if(mosaicoUser.isLogged()) {
                    return Salute(mosaicoManager: widget.initValues["mosaicoManager"]!, mosaicoUser: mosaicoUser,
                      healthManager: healthManager!, backgroundServiceHelper: widget.initValues["backgroundServiceHelper"]!,);
                  } else {
                    return Configura(mosaicoManager: widget.initValues["mosaicoManager"]!, mosaicoUser: mosaicoUser, healthManager: healthManager!,);
                  }
                } else {
                  return Configura(mosaicoManager: widget.initValues["mosaicoManager"]!, mosaicoUser: mosaicoUser, healthManager: healthManager!,);
                }
              },
            );
          },
        )
      )
    );
  }
}