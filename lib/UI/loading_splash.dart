import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          SpinKitSpinningLines(color: Theme.of(context).colorScheme.primary),
          const Spacer()
        ],
      )
    );
  }
}