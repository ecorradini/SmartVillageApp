import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final List<Widget> widgets;
  const RoundedContainer({super.key, required this.widgets});

  @override
  Widget build(BuildContext context) {
    List<Widget> newWidgetList = [];
    for(int i=0; i<widgets.length; i++) {
      Container container = Container(
        alignment: Alignment.centerLeft,
        height: 50,
        child: widgets[i],
      );
      newWidgetList.add(container);
      if(i<widgets.length-1) {
        newWidgetList.add(Divider(height: 1, color: Theme.of(context).colorScheme.background,));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.background,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: newWidgetList,
        ),
      ),
    );
  }
}