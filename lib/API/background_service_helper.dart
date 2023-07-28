import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/notification_service.dart';

import 'api_manager.dart';
import 'health_manager.dart';

class BackgroundServiceHelper {
  static Future<void> enableBackgroundService() async {
    LocalNotificationService.initialize();
    final config = BackgroundFetchConfig(minimumFetchInterval: 15, requiredNetworkType: NetworkType.ANY);
    int status = await BackgroundFetch.configure(
        config,
        (String taskId) async {
          // This is the fetch-event callback.
          print("Background received taskId: $taskId");

          // Use a switch statement to route task-handling.
          switch (taskId) {
            case 'com.transistorsoft.smartvillagefetch':
              print("Received custom task");
              await _onBackgroundUpdate();
              break;
            default:
              print("Default fetch task");
              await _onBackgroundUpdate();
          }
          // Finish, providing received taskId.
          BackgroundFetch.finish(taskId);
      },
      (String taskId) async {  // <-- Event timeout callback
        // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
        print("[BackgroundFetch] TIMEOUT taskId: $taskId");
        BackgroundFetch.finish(taskId);
      }
    );
    print("Background status: $status");
  }

  static Future<void> stopService() async {
    await BackgroundFetch.stop("com.transistorsoft.smartvillagefetch");
    await BackgroundFetch.stop("com.transistorsoft.fetch");
  }

  static Future<void> _onBackgroundUpdate() async {
    HealthManager.healthSetup();
    Map<String,dynamic> allReads = await HealthManager.readData();
    String uploadedId = await APIManager.uploadMeasurements(
      valuesHR: allReads[APIManager.HEART_RATE_IDENTIFIER],
      valuesBP: allReads[APIManager.BLOOD_PRESSURE_IDENTIFIER],
      valuesOS: allReads[APIManager.OXYGEN_SATURATION_IDENTIFIER],
      valuesBMI: allReads[APIManager.BODY_MASS_INDEX_IDENTIFIER],
      valuesBFP: allReads[APIManager.BODY_FAT_PERCENTAGE_IDENTIFIER],
      valuesLBM: allReads[APIManager.LEAN_BODY_MASS_IDENTIFIER],
      valuesW: allReads[APIManager.WEIGHT_IDENTIFIER],
      valuesECG: allReads[APIManager.ECG_IDENTIFIER],
    );
    if(!uploadedId.contains("error_")) {
      APIManager.lastMeasurementID = uploadedId;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("lastMeasurementID", uploadedId);
      await HealthManager.readLastMeasurementsUpload();
      print("UPLOADED: ${await APIManager.getLastMeasurements()}");
      LocalNotificationService.showNotification();
    }

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.smartvillagefetch",
        delay: 90 * 1000  // <-- milliseconds
    ));
  }
}