import 'package:flutter/material.dart';

import 'app_bar.dart';

class SmartVillageScaffold extends StatefulWidget {
  final bool loading;
  final Widget child;
  final String? appBarTitle;
  final bool smallBar;
  const SmartVillageScaffold({super.key, this.loading = false, required this.child, this.appBarTitle, this.smallBar = false});

  @override
  SmartVillageScaffoldState createState() => SmartVillageScaffoldState();
}

class SmartVillageScaffoldState extends State<SmartVillageScaffold> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: widget.loading,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(widget.smallBar ? 50 : 100.0), // here the desired height
              child: SmartVillageAppBar(title: widget.smallBar ? "" : widget.appBarTitle, background: Theme.of(context).colorScheme.background,)
          ),
          resizeToAvoidBottomInset: true,
          body: Padding(
            padding: EdgeInsets.only(left: 18, right: 18, top: widget.smallBar ? 10 : 30),
            child: widget.child,
          ),
        )
    );
  }
}