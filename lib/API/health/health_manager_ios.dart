import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/health/health_manager.dart';
import 'package:health/health.dart';
import 'package:smartvillage/API/mosaico/mosaico_ecg.dart';
import 'package:smartvillage/API/mosaico/mosaico_measurement.dart';
import 'package:smartvillage/API/mosaico/upload_manager.dart';

class HealthManagerIOS extends HealthManager {

  Health health = Health();

  HealthManagerIOS() {
    healthTypes = List<HealthDataType>.from([
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.WEIGHT,
      HealthDataType.ELECTROCARDIOGRAM,
    ]);

    //Richiedo uso Health
    health.configure();
  }

  ///Metodo per ottenere i dati di un certo tipo di misurazione dalla ultima data di registrazione in Mosaico alla data attuale
  Future<List<HealthDataPoint>> _requestHealthData(String mosaicoIdentifier, HealthDataType type) async {
    DateTime lastMeasureDate = await uploadManager.getLastMeasurementDate(mosaicoIdentifier);
    DateTime now = DateTime.now();
    print("${type.name} reading data from: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(lastMeasureDate)} to ${DateFormat("yyyy-MM-dd HH:mm:ss").format(now)}");
    return await health.getHealthDataFromTypes(types: [type], startTime: lastMeasureDate, endTime: now);
  }

  @override
  Future<void> readBFP(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.BODY_FAT_PERCENTAGE_IDENTIFIER, HealthDataType.BODY_FAT_PERCENTAGE);
    if(healthData.isNotEmpty) {
      for (HealthDataPoint point in healthData) {
        res.add(MosaicoMeasurement.fromHealthDataPoint(point));
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.BODY_FAT_PERCENTAGE_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readBMI(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.BODY_MASS_INDEX_IDENTIFIER, HealthDataType.BODY_MASS_INDEX);
    if(healthData.isNotEmpty) {
      for (HealthDataPoint point in healthData) {
        res.add(MosaicoMeasurement.fromHealthDataPoint(point));
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.BODY_MASS_INDEX_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readBloodPressure(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthDataSYS = await _requestHealthData("_MaxBloodPressure", HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
    List<HealthDataPoint> healthDataDIA = await _requestHealthData("_MaxBloodPressure", HealthDataType.BLOOD_PRESSURE_DIASTOLIC);

    //Creo dict di appoggio per stessedate
    Map<DateTime,Map<String,HealthDataPoint?>> app = {};
    for(HealthDataPoint point in healthDataSYS) {
      app[point.dateFrom] = {"point0": point, "point1": null};
    }
    for(HealthDataPoint point in healthDataDIA) {
      //Lo inserisco solo se già esiste point0 in quella data
      if(app.containsKey(point.dateFrom)) {
        app[point.dateFrom]!["point1"] = point;
      }
    }
    if(app.isNotEmpty) {
      for (MapEntry<DateTime, Map<String,HealthDataPoint?>> entry in app.entries) {
        if(entry.value["point1"] != null) {
          res.add(MosaicoMeasurement.fromHealthDataPoints(entry.value["point0"]!, entry.value["point1"]!));
        }
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.BLOOD_PRESSURE_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readECG(String cf) async {
    List<MosaicoECG> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.ECG_IDENTIFIER, HealthDataType.ELECTROCARDIOGRAM);
    for(HealthDataPoint point in healthData) {
      res.add(MosaicoECG.fromHealthDataPoint(point));
    }
    //Carico ECG uno ad uno
    for(MosaicoECG ecg in res) {
      await uploadManager.uploadMeasurement(MosaicoUploadManager.ECG_IDENTIFIER, [ecg], cf);
    }
  }

  @override
  Future<void> readHeartRate(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.HEART_RATE_IDENTIFIER, HealthDataType.HEART_RATE);
    if(healthData.isNotEmpty) {
      for (HealthDataPoint point in healthData) {
        if (!point.sourceName.toLowerCase().contains("watch")) {
          res.add(MosaicoMeasurement.fromHealthDataPoint(point));
        }
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.HEART_RATE_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readHeartRateWatch(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.HEART_RATE_AW_IDENTIFIER, HealthDataType.HEART_RATE);
    if(healthData.isNotEmpty) {
      for (HealthDataPoint point in healthData) {
        if(point.sourceName.toLowerCase().contains("watch")) {
          res.add(MosaicoMeasurement.fromHealthDataPoint(point));
        }
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.HEART_RATE_AW_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readLBM(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> weights = await _requestHealthData(MosaicoUploadManager.LEAN_BODY_MASS_IDENTIFIER, HealthDataType.WEIGHT);
    List<HealthDataPoint> bodyFats = await _requestHealthData(MosaicoUploadManager.LEAN_BODY_MASS_IDENTIFIER, HealthDataType.BODY_FAT_PERCENTAGE);

    // Creo dict di appoggio per date
    Map<DateTime,dynamic> app = {};
    for(HealthDataPoint point in weights) {
      String device = point.sourceName;
      DateTime dateTime = point.dateFrom;
      double weight = point.value.toJson()['numeric_value'] as double;
      app[dateTime] = {"device": device, "weight": weight * 1000};
    }
    for(HealthDataPoint point in bodyFats) {
      DateTime dateTime = point.dateFrom;
      double fat = point.value.toJson()['numeric_value'] as double;
      if(app.containsKey(dateTime)) {
        app[dateTime]["fat"] = fat;
      }
    }
    if(app.isNotEmpty) {
      for (MapEntry<DateTime, dynamic> entry in app.entries) {
        if((entry.value as Map<String, dynamic>).containsKey("weight") && (entry.value as Map<String, dynamic>).containsKey("fat")) {
          double weight = (entry.value as Map<String, dynamic>)["weight"];
          double fat = (entry.value as Map<String, dynamic>)["fat"];
          double value0 = weight - (weight * fat);
          res.add(MosaicoMeasurement(date: entry.key, value0: value0, device: (entry.value as Map<String, dynamic>)["device"]));
        }
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.LEAN_BODY_MASS_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readOxygenSaturation(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.OXYGEN_SATURATION_IDENTIFIER, HealthDataType.BLOOD_OXYGEN);
    if(healthData.isNotEmpty) {
      for (HealthDataPoint point in healthData) {
        res.add(MosaicoMeasurement.fromHealthDataPoint(point));
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.OXYGEN_SATURATION_IDENTIFIER, res, cf);
  }

  @override
  Future<void> readWeight(String cf) async {
    List<MosaicoMeasurement> res = [];
    List<HealthDataPoint> healthData = await _requestHealthData(MosaicoUploadManager.WEIGHT_IDENTIFIER, HealthDataType.WEIGHT);
    if(healthData.isNotEmpty) {
      for (HealthDataPoint point in healthData) {
        res.add(MosaicoMeasurement.fromHealthDataPoint(point));
      }
    }

    await uploadManager.uploadMeasurement(MosaicoUploadManager.WEIGHT_IDENTIFIER, res, cf);
  }

  @override
  Future<bool> requestPermissions() async {
    return await health.requestAuthorization(healthTypes as List<HealthDataType>) ?? false;
  }
}