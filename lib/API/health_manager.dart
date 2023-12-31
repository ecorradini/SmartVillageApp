import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:smartvillage/API/api_manager.dart';

import 'notification_service.dart';

class HealthManager {

  static HealthFactory? healthFactory;
  static DateTime? lastMeasurementsUpload;

  static var types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.WEIGHT,
    HealthDataType.ELECTROCARDIOGRAM,
  ];

  static Map<int, String> ECG_VALUES = {
    ElectrocardiogramClassification.NOT_SET.value: "Nessuna classificazione",
    ElectrocardiogramClassification.SINUS_RHYTHM.value: "Ritmo sinusale.",
    ElectrocardiogramClassification.ATRIAL_FIBRILLATION.value: "Fibrillazione atriale.",
    ElectrocardiogramClassification.INCONCLUSIVE_LOW_HEART_RATE.value: "Bassa frequenza cardiaca.",
    ElectrocardiogramClassification.INCONCLUSIVE_HIGH_HEART_RATE.value: "Elevata frequenza cardiaca.",
    ElectrocardiogramClassification.INCONCLUSIVE_POOR_READING.value: "Lettura inadeguata.",
    ElectrocardiogramClassification.INCONCLUSIVE_OTHER.value: "Altri motivi.",
    ElectrocardiogramClassification.UNRECOGNIZED.value: "Ritmo non riconosciuto."
  };

  static bool currentlyUploading = false;

  static void healthSetup() {
    //Richiedo uso Health
    healthFactory = HealthFactory(useHealthConnectIfAvailable: true);
  }

  static void revokePermissions() async {
    await healthFactory?.revokePermissions();
}

  //Richiedo permesso uso HealthKit
  static Future<bool> requestPermissions() async {
    return await healthFactory?.requestAuthorization(types) ?? false;
  }

  static Future<Map<String,dynamic>> _readData() async {
    List<Map<String,dynamic>> heartRateRead = _convertFromMapToList(await _readHeartRate());
    List<Map<String,dynamic>> heartAWRateRead = _convertFromMapToList(await _readHeartRateAW());
    List<Map<String,dynamic>> bloodPressureRateRead = _convertFromMapToList(await _readBloodPressure());
    List<Map<String,dynamic>> oxygenSaturationRead = _convertFromMapToList(await _readOxygenSaturation());
    List<Map<String,dynamic>> bmiRead = _convertFromMapToList(await _readBMI());
    List<Map<String,dynamic>> lbmRead = _convertFromMapToList(await _readLBM());
    List<Map<String,dynamic>> bfpRead = _convertFromMapToList(await _readBFP());
    List<Map<String,dynamic>> weightRead = _convertFromMapToList(await _readWeight());
    List<Map<String,dynamic>> ecgRead = _convertECGFromMapToList(await _readECG());
    print(ecgRead);

    Map<String,dynamic> res = {
      APIManager.HEART_RATE_IDENTIFIER: heartRateRead.isNotEmpty ? heartRateRead : null,
      APIManager.HEART_RATE_AW_IDENTIFIER : heartAWRateRead.isNotEmpty ? heartAWRateRead : null,
      APIManager.BLOOD_PRESSURE_IDENTIFIER: bloodPressureRateRead.isNotEmpty ? bloodPressureRateRead : null,
      APIManager.OXYGEN_SATURATION_IDENTIFIER: oxygenSaturationRead.isNotEmpty ? oxygenSaturationRead : null,
      APIManager.BODY_MASS_INDEX_IDENTIFIER: bmiRead.isNotEmpty ? bmiRead : null,
      APIManager.LEAN_BODY_MASS_IDENTIFIER: lbmRead.isNotEmpty ? lbmRead : null,
      APIManager.BODY_FAT_PERCENTAGE: bfpRead.isNotEmpty ? bfpRead : null,
      APIManager.WEIGHT_IDENTIFIER: weightRead.isNotEmpty ? weightRead : null,
      APIManager.ECG_IDENTIFIER: ecgRead.isNotEmpty ? ecgRead : null
    };

    return res;
  }

  static Future<void> writeData()  async {
    if(!currentlyUploading) {
      currentlyUploading = true;
      healthSetup();
      Map<String, dynamic> allReads = await _readData();
      await APIManager.uploadECGs(valuesECG: allReads[APIManager.ECG_IDENTIFIER]);
      String lastDate = await APIManager.uploadMeasurements(
        valuesHR: allReads[APIManager.HEART_RATE_IDENTIFIER],
        valuesHRAW: allReads[APIManager.HEART_RATE_AW_IDENTIFIER],
        valuesBP: allReads[APIManager.BLOOD_PRESSURE_IDENTIFIER],
        valuesOS: allReads[APIManager.OXYGEN_SATURATION_IDENTIFIER],
        valuesBMI: allReads[APIManager.BODY_MASS_INDEX_IDENTIFIER],
        valuesLBM: allReads[APIManager.LEAN_BODY_MASS_IDENTIFIER],
        valuesBFP: allReads[APIManager.BODY_FAT_PERCENTAGE],
        valuesW: allReads[APIManager.WEIGHT_IDENTIFIER],
      );
      if (!lastDate.contains("error_")) {
        //await _saveLastDates();
        try {
          lastMeasurementsUpload = DateFormat("MMMM, dd yyyy HH:mm:ss Z").parse(lastDate);
        } catch (_) {
          lastMeasurementsUpload = DateFormat("yyyy-MM-dd HH:mmm:ss").parse(lastDate);
        }
        print("LAST UPLOADED: $lastDate");
        LocalNotificationService.showNotification("Dati sincronizzati in background.");
      }
      currentlyUploading = false;
    }
    //await BackgroundServiceHelper.enableBackgroundService();
  }

  static Future<Map<String,dynamic>> _readHeartRate() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.HEART_RATE_IDENTIFIER);
    Map<String,dynamic> res = await _genericRead(HealthDataType.HEART_RATE,lastMeasureDate);
    Map<String,dynamic> finalRes = {};
    for(String date in res.keys) {
      if(!res[date]["device"].toString().toLowerCase().contains("watch")) {
        finalRes[date] = res[date];
      }
    }
    return finalRes;
  }

  static Future<Map<String,dynamic>> _readHeartRateAW() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.HEART_RATE_AW_IDENTIFIER);
    Map<String,dynamic> res = await _genericRead(HealthDataType.HEART_RATE, lastMeasureDate);
    Map<String,dynamic> finalRes = {};
    for(String date in res.keys) {
      if(res[date]["device"].toString().toLowerCase().contains("watch")) {
        finalRes[date] = res[date];
      }
    }
    return finalRes;
  }

  static Future<Map<String,dynamic>> _readBloodPressure() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate("_MaxBloodPressure");
    Map<String,dynamic> res1 = await _genericRead(HealthDataType.BLOOD_PRESSURE_SYSTOLIC, lastMeasureDate);
    Map<String,dynamic> res2 = await _genericRead(HealthDataType.BLOOD_PRESSURE_DIASTOLIC, lastMeasureDate);
    //Metto DIASTOLIC in value1 di un dizionario complessivo.
    Map<String,dynamic> res = {};
    for(String date in res1.keys) {
      res[date] = {
        "device": res1[date]["device"],
        "value0": res1[date]["value0"],
        "value1": res2[date]["value0"]
      };
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readOxygenSaturation() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.OXYGEN_SATURATION_IDENTIFIER);
    Map<String,dynamic> res = await _genericRead(HealthDataType.BLOOD_OXYGEN, lastMeasureDate);
    return res;
  }

  static Future<Map<String,dynamic>> _readBMI() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.BODY_MASS_INDEX_IDENTIFIER);
    Map<String,dynamic> res = await _genericRead(HealthDataType.BODY_MASS_INDEX, lastMeasureDate);
    return res;
  }

  static Future<Map<String,dynamic>> _readLBM() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.WEIGHT_IDENTIFIER);
    Map<String,dynamic> resW = await _genericRead(HealthDataType.WEIGHT, lastMeasureDate);
    Map<String,dynamic> resBFP = await _genericRead(HealthDataType.BODY_FAT_PERCENTAGE, lastMeasureDate);
    Map<String,dynamic> res = {};
    for(String date in resW.keys) {
      try {
        double weight = resW[date]["value0"];
        double perc = resBFP[date]["value0"];
        double lbm = (weight - (weight * perc)) * 1000;
        res[date] = {
          "device": resW[date]["device"],
          "value0": lbm
        };
      } catch(_) {}
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readBFP() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.BODY_FAT_PERCENTAGE);
    Map<String,dynamic> res = await _genericRead(HealthDataType.BODY_FAT_PERCENTAGE, lastMeasureDate);
    return res;
  }

  static Future<Map<String,dynamic>> _readWeight() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.WEIGHT_IDENTIFIER);
    Map<String,dynamic> resW = await _genericRead(HealthDataType.WEIGHT, lastMeasureDate);
    Map<String,dynamic> res = {};
    for(String date in resW.keys) {
      double weight = resW[date]["value0"];
      res[date] = {
        "device": resW[date]["device"],
        "value0": weight*1000
      };
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readECG() async {
    DateTime lastMeasureDate = await APIManager.getLastMeasurementDate(APIManager.ECG_IDENTIFIER);
    Map<String,dynamic> res = await _genericRead(HealthDataType.ELECTROCARDIOGRAM, lastMeasureDate);
    return res;
  }

  static Future<Map<String,dynamic>> _genericRead(HealthDataType type, DateTime lastMeasureDate) async {
    Map<String,dynamic> res = {};
    DateTime now = DateTime.now();
    print("${type.name} reading data from: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(lastMeasureDate)} to ${DateFormat("yyyy-MM-dd HH:mm:ss").format(now)}");
    //List<HealthDataPoint> healthData = await healthFactory!.getHealthDataFromTypes(lastMeasureDate, lastMeasureDate.add(const Duration(days: 30)), [type]);
    List<HealthDataPoint> healthData = await healthFactory!.getHealthDataFromTypes(lastMeasureDate, now, [type]);
    if(healthData.isNotEmpty) {
      healthData.sort((a, b) => a.dateTo.compareTo(b.dateTo));
      for (HealthDataPoint point in healthData) {
        String dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(point.dateFrom);
        if (point.value is ElectrocardiogramHealthValue) {
          String dateTimeTo = DateFormat("yyyy-MM-dd HH:mm:ss").format(point.dateTo);
          List<num> voltageValues = [];
          for (var v in (point.value as ElectrocardiogramHealthValue).voltageValues) {
            voltageValues.add(num.parse(v.voltage.toStringAsFixed(5)));
          }
          num frequence = ((point.value as ElectrocardiogramHealthValue).samplingFrequency ?? 512);
          num averageHeartRate = ((point.value as ElectrocardiogramHealthValue).averageHeartRate ?? 0);
          ElectrocardiogramClassification classification = (point.value as ElectrocardiogramHealthValue).classification;
          res[dateTime] = {
            "values": voltageValues,
            "freq_hz": frequence,
            "endDate": dateTimeTo,
            "startDate": dateTime,
            "averageHR": averageHeartRate,
            "classification": ECG_VALUES[classification.value],
            "val_qnt": voltageValues.length.toInt()
          };
        } else {
          num value0 = num.parse(num.parse(point.value.toString()).toStringAsFixed(5));
          res[dateTime] = {
            "value0": value0,
            "device": point.sourceName
          };
        }
      }
    }
    print(res.length);
    return res;
  }

  static num formatNumberWithPrecisionScale(num value, int precision, int scale) {
    if (value.abs() >= pow(10, 6)) {
      throw ArgumentError('The absolute value must be less than 10^6.');
    }

    // Calculate the factor to use for rounding based on the scale.
    num scaleFactor = pow(10, scale);

    // Round the value to the desired scale.
    num roundedValue = (value * scaleFactor).round() / scaleFactor;

    // Convert the number to a string with the specified scale (decimal places).
    String formattedString = roundedValue.toStringAsFixed(scale);

    // Check if the total number of digits exceeds the precision.
    // If so, it means the integer part is too long.
    if (formattedString.replaceAll('.', '').replaceAll('-', '').length > precision) {
      throw ArgumentError('The total number of digits exceeds the allowed precision.');
    }

    return roundedValue;
  }

  static List<Map<String,dynamic>> _convertFromMapToList(Map<String,dynamic> source) {
    List<Map<String,dynamic>> res = [];
    for(String date in source.keys) {
      res.add({
        "date": date,
        "value0": source[date]["value0"],
        if((source[date] as Map<String,dynamic>).containsKey("value1")) "value1": source[date]["value1"],
        if(!(source[date] as Map<String,dynamic>).containsKey("value1"))"value1": null,
        "device": source[date]["device"]
      });
    }
    return res;
  }

  static List<Map<String,dynamic>> _convertECGFromMapToList(Map<String,dynamic> source) {
    List<Map<String,dynamic>> res = [];
    for(String date in source.keys) {
      res.add({
        "values": source[date]["values"],
        "classification": source[date]["classification"],
        "averageHR": source[date]["averageHR"],
        "val_qnt": source[date]["val_qnt"],
        "freq_hz": source[date]["freq_hz"],
        "endDate": source[date]["endDate"],
        "startDate": source[date]["startDate"],
      });
    }
    return res;
  }
}