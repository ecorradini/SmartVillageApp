import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'package:smartvillage/API/user.dart';
import 'package:smartvillage/UI/loading_splash.dart';
import 'package:smartvillage/UI/main_navigation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wakelock/wakelock.dart';

import 'API/notification_service.dart';
import 'firebase_options.dart';

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

class SmartVillageAppState extends State<SmartVillageApp> with WidgetsBindingObserver {
  late Future<Map<String,dynamic>> initValues;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed:
        Wakelock.enable();
        if(Utente.logged && !BackgroundServiceHelper.enabled && APIManager.healthSync && APIManager.autoSync) {
          BackgroundServiceHelper.enableBackgroundService();
        } else if(Utente.logged && APIManager.healthSync && APIManager.autoSync) {
          HealthManager.writeData();
        }
        break;
      case AppLifecycleState.paused:
        Wakelock.disable();
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    initValues = init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<String,dynamic>> init() async {
    //Firebase setup
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    //Get current endpoints
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference prodRef = database.ref("prod_url");
    DatabaseReference testRef = database.ref("test_url");
    APIManager.prodUrl = (await prodRef.get()).value as String;
    APIManager.testUrl = (await testRef.get()).value as String;
    //Set up automatic update on change
    prodRef.onValue.listen((DatabaseEvent event) {
      APIManager.prodUrl = event.snapshot.value as String;
    });
    testRef.onValue.listen((DatabaseEvent event) {
      APIManager.testUrl = event.snapshot.value as String;
    });

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
    Utente.logged = res["logged"];
    res["loggedFromTest"] = prefs.getBool("loggedFromTest");

    //Setup Health
    HealthManager.healthSetup();
    APIManager.healthSync = prefs.getBool("healthSync") ?? false;
    APIManager.autoSync = prefs.getBool("autoSync") ?? true;
    String? lastMeasurementsDate = prefs.getString("lastDate");
    if(lastMeasurementsDate != null) {
      try {
        HealthManager.lastMeasurementsUpload = DateFormat("MMMM, dd yyyy HH:mm:ss Z").parse(lastMeasurementsDate);
      } catch(_) {
        HealthManager.lastMeasurementsUpload = DateFormat("yyyy-MM-dd HH:mmm:ss").parse(lastMeasurementsDate);
      }
    }
    if(Utente.logged && !BackgroundServiceHelper.enabled && APIManager.healthSync && APIManager.autoSync) {
      BackgroundServiceHelper.enableBackgroundService();
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
      builder: EasyLoading.init(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0, boldText: false),
            child: child!,
          );
        },
      ),
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
            return MainNavigation(initValues: currentValues,);
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
