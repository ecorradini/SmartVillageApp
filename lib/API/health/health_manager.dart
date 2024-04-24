import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/mosaico/upload_manager.dart';
import 'package:smartvillage/API/phone/notification_service.dart';

/// Classe astratta di base che definisce i metodi di Salute
abstract class HealthManager {
  //Se sto al momento caricando
  bool currentlyUploading = false;
  DateTime? lastMeasurementsUpload;
  List<dynamic> healthTypes = [];
  MosaicoUploadManager uploadManager = MosaicoUploadManager();

  Future<void> loadFromPreferences(SharedPreferences prefs) async {
    String? lastMeasurementsDate = prefs.getString("lastDate");
    if(lastMeasurementsDate != null) {
      lastMeasurementsUpload = DateFormat("yyyy-MM-dd HH:mmm:ss").parse(lastMeasurementsDate);
    } else {
      await setLastUploadDateFromMosaico();
    }
  }

  Future<void> setLastUploadDateFromMosaico() async {
    lastMeasurementsUpload = await uploadManager.getLastUploadDate();
    if(lastMeasurementsUpload != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("lastDate", DateFormat("yyyy-MM-dd HH:mmm:ss").format(lastMeasurementsUpload!));
    }
  }

  /// Metodo per richiedere i permessi di Salute
  Future<bool> requestPermissions();

  /// Metodi per la lettura dei dati da Salute, uno per tipo
  /// Leggo Heart Rate
  Future<void> readHeartRate(String cf);
  ///Leggo Heart Rate da Watch
  Future<void> readHeartRateWatch(String cf);
  ///Leggo Pressione Sanguigna
  Future<void> readBloodPressure(String cf);
  ///Leggo Saturazione ossigeno
  Future<void> readOxygenSaturation(String cf);
  ///Leggo Body Mass Index
  Future<void> readBMI(String cf);
  ///Leggo Lean Body Mass
  Future<void> readLBM(String cf);
  ///Leggo Body Fat Percentage
  Future<void> readBFP(String cf);
  ///Leggo Peso
  Future<void> readWeight(String cf);
  ///Leggo Elettrocardiogramma
  Future<void> readECG(String cf);

  ///Metodo per un upload completo
  Future<void> completeUpload(String codiceFiscale) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("bugs");
    if(!currentlyUploading) {
      EasyLoading.show(status: "Sincronizzazione in corso...");
      currentlyUploading = true;
      // Define a list of asynchronous function references
      Map<String, Future<void> Function(String)> functions = {
        MosaicoUploadManager.HEART_RATE_IDENTIFIER: readHeartRate,
        MosaicoUploadManager.HEART_RATE_AW_IDENTIFIER: readHeartRateWatch,
        MosaicoUploadManager.BLOOD_PRESSURE_IDENTIFIER: readBloodPressure,
        MosaicoUploadManager.OXYGEN_SATURATION_IDENTIFIER: readOxygenSaturation,
        MosaicoUploadManager.BODY_MASS_INDEX_IDENTIFIER: readBMI,
        MosaicoUploadManager.LEAN_BODY_MASS_IDENTIFIER: readLBM,
        MosaicoUploadManager.BODY_FAT_PERCENTAGE_IDENTIFIER: readBFP,
        MosaicoUploadManager.WEIGHT_IDENTIFIER: readWeight,
        MosaicoUploadManager.ECG_IDENTIFIER: readECG,
      };

      // Iterate through the list and call each function inside a try-catch block
      for (String key in functions.keys) {
        try {
          // Null check before invoking the function
          if (functions[key] != null) {
            await functions[key]!(codiceFiscale);
          } else {
            // Log or handle the case where the function is not found
            print("Function for $key not found.");
          }
        } on Exception catch (e) {
          await ref.child("${DateTime.now().millisecondsSinceEpoch}").set({
            "health_type": key,
            "user": codiceFiscale,
            "exception": e.toString()
          });
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("lastDate", DateFormat("yyyy-MM-dd HH:mmm:ss").format(await uploadManager.getLastUploadDate()));
      currentlyUploading = false;

      LocalNotificationService.showNotification("Sincronizzazione effettuata");
      EasyLoading.showSuccess("Fatto!");
    }
  }
}