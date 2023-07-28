import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Image(image: AssetImage('assets/logo.png'), height: MediaQuery.of(context).size.height),
          ),
          SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      SpinKitPumpingHeart(color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 40,)
                    ],
                  ),
                ],
              )
          )
        ],
      )
    );
  }
}