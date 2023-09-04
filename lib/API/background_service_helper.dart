import 'package:background_fetch/background_fetch.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:health_kit_reporter/model/update_frequency.dart';
import 'package:smartvillage/API/notification_service.dart';

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
    await observerQuery();
  }

  static Future<void> stopService() async {
    await BackgroundFetch.stop("com.transistorsoft.smartvillagefetch");
    await BackgroundFetch.stop("com.transistorsoft.fetch");
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
    final sub = HealthKitReporter.observerQuery(
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
        print('Updates for observerQuerySub');
        LocalNotificationService.initialize();
        await HealthManager.writeData();
      },
    );
    print('observerQuerySub: $sub');
    final isSet = await HealthKitReporter.enableBackgroundDelivery(
      identifier,
      UpdateFrequency.immediate,
    );
    print('enableBackgroundDelivery: $isSet');
  }
}