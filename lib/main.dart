import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/UI/main_navigation.dart';

void main() {
  runApp(const SmartVillageApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class SmartVillageApp extends StatefulWidget {
  const SmartVillageApp({super.key});

  @override
  SmartVillageAppState createState() => SmartVillageAppState();
}

class SmartVillageAppState extends State<SmartVillageApp> {
  late Future<Map<String,dynamic>> initValues;

  @override
  void initState() {
    initValues = init();
    super.initState();
  }

  Future<Map<String,dynamic>> init() async {
    //USIAMO UN DIZIONARIO NEL CASO IN FUTURO DEBBANO ESSERE AGGIUNGE ULTERIORI INFO DA CARICARE
    Map<String,dynamic> res = {};
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //LOGIN
    res["logged"] = await autoLogin(prefs);

    //TEST MODE
    APIManager.testMode = prefs.getBool("testMode") ?? false;

    return res;
  }

  Future<bool> autoLogin(SharedPreferences prefs) async {
    //Prendo dati login
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");
    String? codiceFiscale = prefs.getString("codiceFiscale");
    //Se dati esistono allora loggo, altrimenti no
    if(email == null || password == null || codiceFiscale == null) {
      return false;
    }
    else {
      //TODO: Auto Login
      return true;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Village',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          brightness: Brightness.light,
          primary: CupertinoColors.systemGreen,
          onPrimary: CupertinoColors.white,
          background: CupertinoColors.lightBackgroundGray,
          onBackground: CupertinoColors.black,
          error: CupertinoColors.destructiveRed,
          onError: CupertinoColors.white
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: initValues,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            Map<String,dynamic> currentValues = snapshot.data!;
            return MainNavigation(initValues: currentValues,);
          } else if(snapshot.connectionState == ConnectionState.waiting) {
            //LOADING SPLASH
            return Container();
          } else {
            //ERROR
            return Container();
          }
        },
      ),
    );
  }
}
