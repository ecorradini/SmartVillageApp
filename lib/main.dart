import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartvillage/UI/main_navigation.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Village',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CupertinoColors.activeGreen),
        useMaterial3: true,
      ),
      home: const MainNavigation(logged: false,),
    );
  }
}
