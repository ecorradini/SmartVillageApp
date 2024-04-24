import 'dart:async';
import 'dart:io' show Platform;

import 'package:background_fetch/background_fetch.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:health_kit_reporter/model/update_frequency.dart';
import 'package:smartvillage/API/phone/notification_service.dart';

import '../health/health_manager.dart';
import '../mosaico/mosaico_user.dart';

class BackgroundServiceHelper {

  Timer? uploadTimer;
  HealthManager _healthManager;
  MosaicoUser _mosaicoUser;
  bool enabled = false;

  BackgroundServiceHelper({required HealthManager healthManager, required MosaicoUser mosaicoUser}) :
      _healthManager = healthManager, _mosaicoUser = mosaicoUser;

  Future<void> enableBackgroundService() async {
    LocalNotificationService.initialize();
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
    if(Platform.isIOS) await observerQuery();
    _startBackgroundTimer();
    enabled = true;
  }

  void _startBackgroundTimer() {
    uploadTimer = Timer.periodic(const Duration(seconds: 180), (timer) {
      print("TIMER");
      _healthManager.completeUpload(_mosaicoUser.getCodiceFiscale()!).then((value) {
        _startBackgroundTimer();
      });
    });
  }

  Future<void> stopService() async {
    await BackgroundFetch.stop("com.transistorsoft.smartvillagefetch");
    await BackgroundFetch.stop("com.transistorsoft.fetch");
    uploadTimer?.cancel();
    enabled = false;
  }

  Future<void> _onBackgroundUpdate() async {
    await _healthManager.completeUpload(_mosaicoUser.getCodiceFiscale()!);

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.smartvillagefetch",
        delay: 90 * 1000  // <-- milliseconds
    ));
  }

  Future<void> observerQuery() async {
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
        await _healthManager.completeUpload(_mosaicoUser.getCodiceFiscale()!);
      },
    );
    await HealthKitReporter.enableBackgroundDelivery(
      identifier,
      UpdateFrequency.immediate,
    );
  }
}