import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/UI/loading_splash.dart';
import 'package:smartvillage/UI/main_navigation.dart';
import 'package:upgrader/upgrader.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
          onError: CupertinoColors.white,
          surface: CupertinoColors.white,
          onSurface: CupertinoColors.black,
            secondary: CupertinoColors.systemGrey
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: CupertinoColors.systemGreen,
          onPrimary: CupertinoColors.white,
          background: CupertinoColors.darkBackgroundGray,
          onBackground: CupertinoColors.white,
          error: CupertinoColors.destructiveRed,
          onError: CupertinoColors.white,
          surface: CupertinoColors.black,
          onSurface: CupertinoColors.white,
          secondary: CupertinoColors.lightBackgroundGray
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: initValues,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            Map<String,dynamic> currentValues = snapshot.data!;
            return UpgradeAlert(
                upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino),
                child: MainNavigation(initValues: currentValues,),
            );
          } else if(snapshot.connectionState == ConnectionState.waiting) {
            //LOADING SPLASH
            return LoadingSplashScreen();
          } else {
            //ERROR
            return Container();
          }
        },
      ),
    );
  }
}
