import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:smartvillage/API/mosaico/mosaico_manager.dart';
import 'package:smartvillage/API/mosaico/mosaico_measurement.dart';

class MosaicoUploadManager extends MosaicoManager {
  /// IDENTIFIERS IN MOSAICO
  static const String BLOOD_PRESSURE_IDENTIFIER = "_BloodPressure";
  static const String HEART_RATE_IDENTIFIER = "_HeartRate";
  static const String HEART_RATE_AW_IDENTIFIER = "_HeartRateAW";
  static const String OXYGEN_SATURATION_IDENTIFIER = "_OxygenSaturation";
  static const String BODY_MASS_INDEX_IDENTIFIER = "_BMI";
  static const String LEAN_BODY_MASS_IDENTIFIER = "_LBM";
  static const String BODY_FAT_PERCENTAGE_IDENTIFIER = "_FBM";
  static const String WEIGHT_IDENTIFIER = "_Weight";
  static const String ECG_IDENTIFIER = "_ECG";

  /// Get the last date in Mosaico of measurement dataType
  Future<DateTime> getLastMeasurementDate(String dataType) async {
    Map<String,dynamic> last10 = await getData(endpoint: "/measurements/medical-data/$dataType");
    List<DateTime> allDates = [];
    if(last10.containsKey("data")) {
      for (Map<String, dynamic> data in last10["data"]) {
        String measurementDate = data["date"];
        allDates.add(DateFormat("MMMM, dd yyyy HH:mm:ssZ").parse(measurementDate));
      }
      if(allDates.isNotEmpty) {
        allDates.sort((a, b) => b.compareTo(a));
        return allDates.first.add(const Duration(seconds: 1));
      }
      else {
        return DateTime.now().subtract(const Duration(days: 170));
      }
    }
    else {
      return DateTime.now().subtract(const Duration(days: 170));
    }
  }

  Future<DateTime> getLastUploadDate() async {
    List<String> dataTypes = [
      BLOOD_PRESSURE_IDENTIFIER,
      HEART_RATE_IDENTIFIER,
      HEART_RATE_AW_IDENTIFIER,
      OXYGEN_SATURATION_IDENTIFIER,
      BODY_MASS_INDEX_IDENTIFIER,
      LEAN_BODY_MASS_IDENTIFIER,
      BODY_FAT_PERCENTAGE_IDENTIFIER,
      WEIGHT_IDENTIFIER,
      ECG_IDENTIFIER
    ];
    List<DateTime> allLastUploads = [];
    for(String type in dataTypes) {
      allLastUploads.add(await getLastMeasurementDate(type));
    }
    return allLastUploads.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  List<List<T>> _splitList<T>(List<T> list, {int chunkSize = 50}) {
    List<List<T>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      int end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  Future<void> uploadMeasurement(String identifier, List<MosaicoMeasurement> measurements, String codiceFiscale) async {
    measurements.sort((a, b) => a.date.compareTo(b.date));
    if(measurements.isNotEmpty && measurements.length > 50) {
      List<List<MosaicoMeasurement>> splitted = _splitList(measurements);
      for(List<MosaicoMeasurement> split in splitted) {
        await uploadMeasurement(identifier, split, codiceFiscale);
      }
    } else if(measurements.isNotEmpty) {
      List<Map<String, dynamic>> values = [];
      for (MosaicoMeasurement measurement in measurements) {
        values.add(measurement.toDict());
      }
      Map<String, dynamic> data = {identifier: values};
      Map<String, dynamic> body = {
        "patient": {
          "fiscalCode": codiceFiscale
        },
        "data": data
      };
      log("BODY: $body");
      Map<String, dynamic> response = await postData(
          parameters: body,
          endpoint: "/measurements"
      );
      if(response.containsKey("error")) {
        DatabaseReference ref = FirebaseDatabase.instance.ref("bugs");
        await ref.child("${DateTime.now().millisecondsSinceEpoch}").set({
          "health_type": identifier,
          "user": codiceFiscale,
          "response": response["error"]
        });
      }
      print("UPLOADED: $response");
    }
  }
}