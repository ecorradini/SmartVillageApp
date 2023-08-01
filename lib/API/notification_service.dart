import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
  DarwinNotificationCategory(
    "baseNotification",
    actions: [],
  ),
];

class LocalNotificationService {
  // Instance of Flutternotification plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    //TODO ANDROID
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: true,
        requestAlertPermission: false,
        notificationCategories: darwinNotificationCategories,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
    );
    _notificationsPlugin.initialize(
        initializationSettings
    );
  }

  static Future<void> requestPermissionsIOS() async {
    await _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future showNotification(String text) async {
    //TODO: WHEN ANDROID
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'SmartVillage',
        'your channel name',
        importance: Importance.max,
        priority: Priority.high
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: true,
        presentSound: false
    );

    // initialise channel platform for both Android and iOS device.
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics
    );
    await _notificationsPlugin.show(0,
        'Smart Village',
        text,
        platformChannelSpecifics,
        payload: 'Default_Sound'
    );
  }
}