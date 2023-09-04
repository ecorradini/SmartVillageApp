import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/API/background_service_helper.dart';
import 'package:smartvillage/API/health_manager.dart';
import 'package:smartvillage/UI/loading_splash.dart';
import 'package:smartvillage/UI/main_navigation.dart';
import 'package:upgrader/upgrader.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'API/notification_service.dart';

void main() {
  runApp(
    Phoenix(
      child: const SmartVillageApp(),
    ),
  );
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<String,dynamic>> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Europe/Rome"));
    await AppTrackingTransparency.requestTrackingAuthorization();
    await LocalNotificationService.requestPermissionsIOS();
    //USIAMO UN DIZIONARIO NEL CASO IN FUTURO DEBBANO ESSERE AGGIUNGE ULTERIORI INFO DA CARICARE
    Map<String,dynamic> res = {};
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //TEST MODE
    APIManager.testMode = prefs.getBool("testMode") ?? false;

    //LOGIN
    res["logged"] = await autoLogin(prefs);
    res["loggedFromTest"] = prefs.getBool("loggedFromTest");

    //Setup Health
    HealthManager.healthSetup();
    APIManager.healthSync = prefs.getBool("healthSync") ?? false;
    APIManager.autoSync = prefs.getBool("autoSync") ?? true;
    if(res["logged"] && APIManager.healthSync && APIManager.autoSync) {
      await HealthManager.writeData();
      await BackgroundServiceHelper.enableBackgroundService();
    }

    return res;
  }

  Future<bool> autoLogin(SharedPreferences prefs) async {
    //Prendo dati login
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");
    //String? codiceFiscale = prefs.getString("codiceFiscale");
    //Se dati esistono allora loggo, altrimenti no
    if(email == null || password == null) {// || codiceFiscale == null) {
      return false;
    }
    else {
      //AUTOLOGIN
      bool logged = await APIManager.login(
          email: email,
          password: password,
          //codiceFiscale: codiceFiscale,
          prefs: prefs,
          context: context
      );
      return logged;
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
          brightness: Brightness.dark,
          primary: Color(0xFFFF7D0B),
          onPrimary: CupertinoColors.white,
          background: Color(0xFF171D5B),
          onBackground: CupertinoColors.white,
          error: Color(0xFFE65150),
          onError: CupertinoColors.white,
          surface: CupertinoColors.white,
          onSurface: CupertinoColors.black,
          secondary: CupertinoColors.systemGrey,
          tertiary: Color(0xFF545A99),
          onTertiary: CupertinoColors.white,
          surfaceVariant: Color(0xFF202880),
          onSurfaceVariant: CupertinoColors.lightBackgroundGray
        ),
        fontFamily: 'ArialRoundedMT',
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      home: FutureBuilder(
        future: initValues,
        builder: (context, snapshot) {
          EasyLoading.instance
            ..indicatorType = EasyLoadingIndicatorType.pumpingHeart
            ..loadingStyle = EasyLoadingStyle.dark
            ..indicatorSize = 45.0
            ..radius = 10.0
            ..progressColor = const Color(0xFFFF7D0B)
            ..backgroundColor = const Color(0xFF545A99)
            ..indicatorColor = const Color(0xFFFF7D0B)
            ..textColor = const Color(0xFFFF7D0B)
            ..userInteractions = false
            ..dismissOnTap = false;
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
            print(snapshot.error!);
            return Container();
          }
        },
      ),
    );
  }
}
