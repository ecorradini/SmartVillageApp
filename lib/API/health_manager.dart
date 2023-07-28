import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/api_manager.dart';

class HealthManager {

  static HealthFactory? healthFactory;

  static DateTime? lastReadHeartRate;
  static DateTime? lastReadBloodPressure;
  static DateTime? lastReadOxygenSaturation;
  static DateTime? lastReadBMI;
  static DateTime? lastReadBFP;
  static DateTime? lastReadLBM;
  static DateTime? lastReadWeight;
  static DateTime? lastReadECG;

  static DateTime? lastMeasurementsUpload;

  static var types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.WEIGHT,
    HealthDataType.ELECTROCARDIOGRAM
  ];

  static void healthSetup() {
    //Richiedo uso Health
    healthFactory = HealthFactory(useHealthConnectIfAvailable: true);
  }

  //Richiedo permesso uso HealthKit
  static Future<bool> requestPermissions() async {
    return await healthFactory?.requestAuthorization(types) ?? false;
  }

  static Future<Map<String,dynamic>> readData() async {
    List<Map<String,dynamic>> heartRateRead = _convertFromMapToList(await _readHeartRate());
    List<Map<String,dynamic>> bloodPressureRateRead = _convertFromMapToList(await _readBloodPressure());
    List<Map<String,dynamic>> oxygenSaturationRead = _convertFromMapToList(await _readOxygenSaturation());
    List<Map<String,dynamic>> bmiRead = _convertFromMapToList(await _readBMI());
    List<Map<String,dynamic>> bfpRead = _convertFromMapToList(await _readBFP());
    List<Map<String,dynamic>> lbmRead = _convertFromMapToList(await _readLBM());
    List<Map<String,dynamic>> weightRead = _convertFromMapToList(await _readWeight());
    //TODO: ECG

    Map<String,dynamic> res = {
      APIManager.HEART_RATE_IDENTIFIER: heartRateRead.isNotEmpty ? heartRateRead : null,
      APIManager.BLOOD_PRESSURE_IDENTIFIER: bloodPressureRateRead.isNotEmpty ? bloodPressureRateRead : null,
      APIManager.OXYGEN_SATURATION_IDENTIFIER: oxygenSaturationRead.isNotEmpty ? oxygenSaturationRead : null,
      APIManager.BODY_MASS_INDEX_IDENTIFIER: bmiRead.isNotEmpty ? bmiRead : null,
      APIManager.BODY_FAT_PERCENTAGE_IDENTIFIER: bfpRead.isNotEmpty ? bfpRead : null,
      APIManager.LEAN_BODY_MASS_IDENTIFIER: lbmRead.isNotEmpty ? lbmRead : null,
      APIManager.WEIGHT_IDENTIFIER: weightRead.isNotEmpty ? weightRead : null,
      APIManager.ECG_IDENTIFIER: null //TODO: ECG
    };

    await _saveLastDates();

    return res;
  }

  static Future<void> _saveLastDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(lastReadHeartRate != null) {
      prefs.setString("lastReadHeartRate",
          DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadHeartRate!));
    }
    if(lastReadBloodPressure != null) {
      prefs.setString("lastReadBloodPressure",
          DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadBloodPressure!));
    }
    if(lastReadOxygenSaturation != null) {
      prefs.setString("lastReadOxygenSaturation",
          DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadOxygenSaturation!));
    }
    if(lastReadBMI != null) {
      prefs.setString(
          "lastReadBMI", DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadBMI!));
    }
    if(lastReadBFP != null) {
      prefs.setString(
          "lastReadBFP", DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadBFP!));
    }
    if(lastReadLBM != null) {
      prefs.setString("lastReadLBM",
          DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadLBM!));
    }
    if(lastReadWeight != null) {
      prefs.setString("lastReadWeight",
          DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadWeight!));
    }
    if(lastReadECG != null) {
      prefs.setString(
          "lastReadECG", DateFormat("yyyy-MM-dd HH:mm:ss").format(lastReadECG!));
    }
  }

  static Future<void> readLastDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastReadHeartRateS = prefs.getString("lastReadHeartRate");
    String? lastReadBloodPressureS = prefs.getString("lastReadBloodPressure");
    String? lastReadOxygenSaturationS = prefs.getString("lastReadOxygenSaturation");
    String? lastReadBMIS = prefs.getString("lastReadBMI");
    String? lastReadBFPS = prefs.getString("lastReadBFP");
    String? lastReadLBMS = prefs.getString("lastReadLBM");
    String? lastReadWeightS = prefs.getString("lastReadWeight");
    String? lastReadECGS = prefs.getString("lastReadECG");
    if(lastReadHeartRateS != null) {
      lastReadHeartRate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadHeartRateS);
    }
    if(lastReadBloodPressureS != null) {
      lastReadBloodPressure = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadBloodPressureS);
    }
    if(lastReadOxygenSaturationS != null) {
      lastReadOxygenSaturation = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadOxygenSaturationS);
    }
    if(lastReadBMIS != null) {
      lastReadBMI = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadBMIS);
    }
    if(lastReadBFPS != null) {
      lastReadBFP = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadBFPS);
    }
    if(lastReadLBMS != null) {
      lastReadLBM = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadLBMS);
    }
    if(lastReadWeightS != null) {
      lastReadWeight = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadWeightS);
    }
    if(lastReadECGS != null) {
      lastReadECG = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastReadECGS);
    }
  }

  static Future<void> readLastMeasurementsUpload() async {
    lastMeasurementsUpload = await APIManager.getLastMeasurementDate();
    print("LAST MEASUREMENTS upload = $lastMeasurementsUpload");
  }

  static Future<Map<String,dynamic>> _readHeartRate() async {
    Map<String,dynamic> res = await _genericRead(HealthDataType.HEART_RATE, lastReadHeartRate);
    if(res.isNotEmpty) {
      lastReadHeartRate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readBloodPressure() async {
    Map<String,dynamic> res1 = await _genericRead(HealthDataType.BLOOD_PRESSURE_SYSTOLIC, lastReadBloodPressure);
    Map<String,dynamic> res2 = await _genericRead(HealthDataType.BLOOD_PRESSURE_DIASTOLIC, lastReadBloodPressure);
    //Metto DIASTOLIC in value1 di un dizionario complessivo.
    Map<String,dynamic> res = {};
    for(String date in res1.keys) {
      res[date] = {
        "device": res1[date]["device"],
        "value0": res1[date]["value0"],
        "value1": res2[date]["value0"]
      };
    }
    if(res.isNotEmpty) {
      lastReadBloodPressure = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readOxygenSaturation() async {
    Map<String,dynamic> res = await _genericRead(HealthDataType.BLOOD_OXYGEN, lastReadOxygenSaturation);
    if(res.isNotEmpty) {
      lastReadOxygenSaturation = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readBMI() async {
    Map<String,dynamic> res = await _genericRead(HealthDataType.BODY_MASS_INDEX, lastReadBMI);
    if(res.isNotEmpty) {
      lastReadBMI = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readBFP() async {
    Map<String,dynamic> res = await _genericRead(HealthDataType.BODY_FAT_PERCENTAGE, lastReadBFP);
    if(res.isNotEmpty) {
      lastReadBFP = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readLBM() async {
    Map<String,dynamic> resW = await _genericRead(HealthDataType.WEIGHT, lastReadLBM);
    Map<String,dynamic> resBFP = await _genericRead(HealthDataType.BODY_FAT_PERCENTAGE, lastReadLBM);
    Map<String,dynamic> res = {};
    for(String date in resW.keys) {
      double weight = resW[date]["value0"];
      double perc = resBFP[date]["value0"];
      double lbm = weight - ((weight*perc)/100);
      res[date] = {
        "device": resW[date]["device"],
        "value0": lbm
      };
    }
    if(res.isNotEmpty) {
      lastReadLBM = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  static Future<Map<String,dynamic>> _readWeight() async {
    Map<String,dynamic> res = await _genericRead(HealthDataType.WEIGHT, lastReadWeight);
    if(res.isNotEmpty) {
      lastReadWeight = DateFormat("yyyy-MM-dd HH:mm:ss").parse(res.keys.first);
    }
    return res;
  }

  //TODO: ECG

  static Future<Map<String,dynamic>> _genericRead(HealthDataType type, DateTime? lastRead) async {
    Map<String,dynamic> res = {};
    DateTime now = DateTime.now();
    Duration duration = const Duration(days: 1);
    if(lastRead != null) {
      duration = now.difference(lastRead);
    }
    List<HealthDataPoint> healthData = await healthFactory!.getHealthDataFromTypes(now.subtract(duration), now, [type]);
    for(HealthDataPoint point in healthData) {
      String dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(point.dateFrom);
      int value0 = double.parse(point.value.toString()).toInt();
      String deviceId = point.deviceId;
      res[dateTime] = {
        "value0": value0,
        "device": deviceId
      };
    }
    return res;
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
}