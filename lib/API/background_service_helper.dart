import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:health_kit_reporter/model/update_frequency.dart';
import 'package:smartvillage/API/notification_service.dart';

import 'health_manager.dart';

class BackgroundServiceHelper {

  static Timer? uploadTimer;
  static bool enabled = false;

  static Future<void> enableBackgroundService() async {
    LocalNotificationService.initialize();
    _startBackgroundTimer();
    final config = BackgroundFetchConfig(minimumFetchInterval: 1, requiredNetworkType: NetworkType.ANY);
    int status = await BackgroundFetch.configure(
        config,
        (String taskId) async {
          // Use a switch statement to route task-handling.
          switch (taskId) {
            case 'com.transistorsoft.smartvillagefetch':
              print("FETCH");
              await _onBackgroundUpdate();
              break;
            default:
              print("FETCH");
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
    await observerQuery();
    enabled = true;
  }

  static Future<void> stopService() async {
    await BackgroundFetch.stop("com.transistorsoft.smartvillagefetch");
    await BackgroundFetch.stop("com.transistorsoft.fetch");
    _stopBackgroundTimer();
    enabled = false;
  }

  static void _startBackgroundTimer() {
    uploadTimer = Timer.periodic(const Duration(seconds: 180), (timer) {
      print("TIMER");
      HealthManager.writeData();
      _startBackgroundTimer();
    });
  }

  static void _stopBackgroundTimer() {
    uploadTimer?.cancel();
  }

  static Future<void> _onBackgroundUpdate() async {
    await HealthManager.writeData();

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.smartvillagefetch",
        delay: 90 * 1000  // <-- milliseconds
    ));
  }

  static Future<void> observerQuery() async {
    final identifier = QuantityType.vo2Max.identifier;
    HealthKitReporter.observerQuery(
      [
        QuantityType.heartRate.identifier,
        QuantityType.vo2Max.identifier,
        QuantityType.bloodPressureDiastolic.identifier,
        QuantityType.bloodPressureSystolic.identifier,
        QuantityType.oxygenSaturation.identifier,
        QuantityType.bodyMassIndex.identifier,
        QuantityType.bodyFatPercentage.identifier,
        QuantityType.bodyMass.identifier,
      ],
      Predicate(DateTime.now().add(const Duration(seconds: -180)), DateTime.now()),
      onUpdate: (identifier) async {
        print('OBSERVERQUERY');
        LocalNotificationService.initialize();
        await HealthManager.writeData();
      },
    );
    await HealthKitReporter.enableBackgroundDelivery(
      identifier,
      UpdateFrequency.immediate,
    );
  }
}