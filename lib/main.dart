import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/health/health_manager_android.dart';
import 'package:smartvillage/API/phone/background_service_helper.dart';
import 'package:smartvillage/API/health/health_manager_ios.dart';
import 'package:smartvillage/API/mosaico/user_manager.dart';
import 'package:smartvillage/UI/loading_splash.dart';
import 'package:smartvillage/UI/main_navigation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wakelock/wakelock.dart';

import 'API/health/health_manager.dart';
import 'API/mosaico/mosaico_manager.dart';
import 'API/mosaico/mosaico_user.dart';
import 'API/phone/notification_service.dart';
import 'API/phone/firebase_options.dart';

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

  HealthManager? healthManager;
  MosaicoUser mosaicoUser = MosaicoUser();
  MosaicoManager mosaicoManager = MosaicoManager();
  MosaicoUserManager mosaicoUserManager = MosaicoUserManager();
  BackgroundServiceHelper? backgroundServiceHelper;
  late Future<Map<String,dynamic>> initValues;
  bool firstRun = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed:
        Wakelock.enable();
        if(healthManager != null && mosaicoUser.isLogged() && mosaicoManager.healthSync && mosaicoManager.autoSync) {
          setState(() {
            healthManager!.currentlyUploading = true;
          });
          healthManager!.completeUpload(mosaicoUser.getCodiceFiscale()!).then((value) {
            setState(() {});
          });
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
    if(Platform.isIOS) {
      healthManager = HealthManagerIOS();
    } else if(Platform.isAndroid) {
      healthManager = HealthManagerAndroid();
    }
    initValues = init();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Tutta l'inizializzazione necessaria
  Future<Map<String,dynamic>> init() async {
    //Preferences del telefono
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Ricarico se esiste MosaicoManager
    mosaicoManager.loadFromPreferences(prefs);
    //Firebase setup
    await Firebase.initializeApp(
      name: 'smartvillage',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //Get current endpoints
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference prodRef = database.ref("prod_url");
    DatabaseReference testRef = database.ref("test_url");
    MosaicoManager.prodUrl = (await prodRef.get()).value as String;
    MosaicoManager.testUrl = (await testRef.get()).value as String;
    //Set up automatic update on change
    prodRef.onValue.listen((DatabaseEvent event) {
      MosaicoManager.prodUrl = event.snapshot.value as String;
    });
    testRef.onValue.listen((DatabaseEvent event) {
      MosaicoManager.testUrl = event.snapshot.value as String;
    });

    //Setup notifiche e permessi
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Europe/Rome"));
    if(Platform.isIOS) await AppTrackingTransparency.requestTrackingAuthorization();
    if(Platform.isIOS) await LocalNotificationService.requestPermissionsIOS();
    if(Platform.isAndroid) await LocalNotificationService.requestPermissionsAndroid();

    //USIAMO UN DIZIONARIO NEL CASO IN FUTURO DEBBANO ESSERE AGGIUNGE ULTERIORI INFO DA CARICARE
    Map<String,dynamic> res = {};

    MosaicoUser? loadedUser = MosaicoUser.loadFromPrefs(prefs);
    //Se precedentemente loggato, ri-eseguo il login
    if(loadedUser != null && loadedUser.hasEmailAndPassword()) {
      MosaicoUser? logged = await mosaicoUserManager.login(email: loadedUser.getEmail()!, password: loadedUser.getPassword()!, prefs: prefs);
      if(logged != null) {
        firstRun = false;
        mosaicoUser = logged;
        //Ricarico se esiste HealthManager
        await healthManager!.loadFromPreferences(prefs);
        backgroundServiceHelper = BackgroundServiceHelper(healthManager: healthManager!, mosaicoUser: mosaicoUser);
        if(!backgroundServiceHelper!.enabled && mosaicoManager.healthSync && mosaicoManager.autoSync) {
          backgroundServiceHelper!.enableBackgroundService();
        }
      }
    }

    //Metto mosaicomanager e healthmanager nel dizionario, così li mandiamo ad altre view
    res["mosaicoManager"] = mosaicoManager;
    res["mosaicoUserManager"] = mosaicoUserManager;
    res["healthManager"] = healthManager;
    res["mosaicoUser"] = mosaicoUser;
    res["backgroundServiceHelper"] = backgroundServiceHelper;

    return res;
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
            print("ERROR: ${snapshot.error!}");
            return Container();
          }
        },
      ),
    );
  }
}
