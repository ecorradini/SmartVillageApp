import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/user.dart';

import '../UI/utilities/error_manager.dart';

class APIManager {
  static const String _PRODURL = "https://services.mosaicoproject.it/api/v2";
  static const String _TESTURL = "https://test-services.mosaicoproject.it/api/v2";
  static const String BLOOD_PRESSURE_IDENTIFIER = "_BloodPressure";
  static const String HEART_RATE_IDENTIFIER = "_HeartRate";
  static const String OXYGEN_SATURATION_IDENTIFIER = "_OxygenSaturation";
  static const String BODY_MASS_INDEX_IDENTIFIER = "_BMI";
  static const String LEAN_BODY_MASS_IDENTIFIER = "_LBM";
  static const String WEIGHT_IDENTIFIER = "_Weight";
  static const String ECG_IDENTIFIER = "_ECG";

  static bool testMode = false;
  static bool healthSync = false;
  static bool autoSync = true;
  static String? authToken;
  static String? refreshToken;

  static Future<Map<String,String>> auth({email = String, password = String}) async {
    Map<String,dynamic> res = await _postData(
      parameters: {
        "email": email,
        "pwd": password
      },
      hook: "auth"
    );
    if(res.containsKey("data")) {
      return {
        "authToken": res["data"]["token"],
        "refreshToken": res["data"]["refreshToken"]
      };
    }
    else if(res.containsKey("errors")) {
      return {"error": "error_${res["errors"]![0]["type"] ?? "Unknown"}"};
    }
    else {
      return {"error": ErrorManager.ERROR_UNKOWN};
    }
  }

  static Future<void> refresh() async {
    final headers = {
      'Authorization': 'Bearer $refreshToken',
    };
    // The URL where you want to send the POST request
    final url = Uri.parse(testMode ? "$_TESTURL/auth/refresh" : "$_PRODURL/auth/refresh");
    try {
      final response = await http.get(url, headers: headers);
      Map<String,dynamic> res = jsonDecode(response.body);
      if(res.containsKey("data")) {
        authToken = res["data"]["token"];
      }
    } catch (e) {
      print("REFRESH $e");
    }
  }

  static Future<String> _getCurrentUser() async {
    Map<String,dynamic> res = await _getData(hook: "auth/user");
    return jsonEncode(res);
  }

  static Future<bool> login({email = String, password = String, prefs = SharedPreferences, context = BuildContext}) async {
    Map<String,String> result = await auth(
        email: email,
        password: password
    );
    if(result.containsKey("error")) {
      if (context.mounted) ErrorManager.showError(context, result["error"]!);
      return false;
    } else {
      authToken = result["authToken"];
      refreshToken = result["refreshToken"];
      String userRes = await _getCurrentUser();
      if(userRes.contains("error_")) {
        if (context.mounted) ErrorManager.showError(context, userRes);
        return false;
      } else {
        Map<String,dynamic> userResDict = jsonDecode(userRes);
        Utente.nome = userResDict["data"]!["name"];
        Utente.cognome = userResDict["data"]!["surname"];
        Utente.email = userResDict["data"]!["account"]!["email"];
        //Utente.dataNascita = patientResDict["data"]!["dateOfBirth"];
        //Utente.genere = patientResDict["data"]!["genre"]!["id"];
        //Utente.codiceEsenzione = patientResDict["data"]!["exemptionCode"];
        Utente.stato = userResDict["status"];
        Utente.created = userResDict["created"];
        Utente.id = userResDict["uuid"];
        Utente.enabledAccount = userResDict["data"]!["account"]!["enabled"].toString();
        //Utente.pin = patientResDict["data"]!["pin"].toString();
        Utente.codiceFiscale = userResDict["data"]!["fiscalCode"].toString();
        prefs.setString("email", email);
        prefs.setString("password", password);
        //prefs.setString("codiceFiscale", codiceFiscale);
        prefs.setBool("loggedFromTest", testMode);
        return true;
      }
    }
  }

  /*static Future<String> getLastUploadDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastMeasurementsId = prefs.getString("lastMeasurementsId");
    if(lastMeasurementsId != null) {
      Map<String, dynamic> last = await _getData(hook: "measurements/$lastMeasurementsId");
      List allData = last["data"];
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(DateFormat("MMMM, dd yyyy HH:mm:ss Z").parse(allData[0]["uploadDate"]));
    }
    else {
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now().subtract(const Duration(minutes: 30)));
    }
  }*/

  /*static Future<Map<String, dynamic>> _downloadLastMeasurements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastMeasurementsId = prefs.getString("lastMeasurementsId");
    if(lastMeasurementsId != null) {
      Map<String, dynamic> last = await _getData(hook: "measurements/$lastMeasurementsId");
      List allData = last["data"];
      Map<String, dynamic> res = {};
      for(Map<String,dynamic> data in allData) {
        String identifier = data["prettyId"];
        String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateFormat("MMMM, dd yyyy HH:mm:ss Z").parse(data["date"]));
        if(res.containsKey(identifier)) {
          (res[identifier] as List<String>).add(date);
        } else {
          res[identifier] = [date];
        }
      }
      return res;
    }
    else {
      return {};
    }
  }

  static Map<String,dynamic> _removeDuplicates(Map<String,dynamic> data, Map<String, dynamic> lastMeasurements) {
    Map<String,dynamic> res = {};
    for(String identifier in data.keys) {
      List<String>? alreadyUploadedDates = lastMeasurements[identifier];
      for(Map<String, dynamic> measurement in data[identifier]) {
        print(measurement);
        String currentDate = measurement["date"];
        if(alreadyUploadedDates == null || !alreadyUploadedDates.contains(currentDate)) {
          if(res.containsKey(identifier)) {
            (res[identifier] as List<Map<String, dynamic>>).add(measurement);
          }
          else {
            res[identifier] = [measurement];
          }
        }
      }
    }
    return res;
  }*/

  static Future<String> uploadMeasurements({
    List<Map<String,dynamic>>? valuesHR,
    List<Map<String,dynamic>>? valuesBP,
    List<Map<String,dynamic>>? valuesOS,
    List<Map<String,dynamic>>? valuesBMI,
    List<Map<String,dynamic>>? valuesLBM,
    List<Map<String,dynamic>>? valuesW,
    List<Map<String,dynamic>>? valuesECG})
  async {
    Map<String, dynamic> data = {
      if(valuesHR != null) HEART_RATE_IDENTIFIER: valuesHR,
      if(valuesBP != null) BLOOD_PRESSURE_IDENTIFIER: valuesBP,
      if(valuesOS != null) OXYGEN_SATURATION_IDENTIFIER: valuesOS,
      if(valuesBMI != null) BODY_MASS_INDEX_IDENTIFIER: valuesBMI,
      if(valuesLBM != null) LEAN_BODY_MASS_IDENTIFIER: valuesLBM,
      if(valuesW != null) WEIGHT_IDENTIFIER: valuesW,
      if(valuesECG != null) ECG_IDENTIFIER: valuesECG
    };
    print("TO UPLOAD $data");
    if(data.isNotEmpty) {
      Map<String, dynamic> parameters = {
        "patient": {
          "fiscalCode": Utente.codiceFiscale
        },
        "data": data,
      };
      Map<String, dynamic> res = await _postData(
          parameters: parameters,
          hook: "measurements"
      );
      if (res.containsKey("data")) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("lastMeasurementsId", res["data"]["id"].toString());
        return res["created"]!;
      }
      else if (res.containsKey("errors")) {
        return "error_${res["errors"]![0]["type"] ?? "Unknown"}";
      }
      else {
        return ErrorManager.ERROR_UNKOWN;
      }
    } else {
      return ErrorManager.ERROR_UNKOWN;
    }
  }

  //Funzione per fare GET
  static Future<Map<String,dynamic>> _getData({hook = String, refreshed = false}) async {
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    final url = Uri.parse(testMode ? "$_TESTURL/$hook" : "$_PRODURL/$hook");
    try {
      if(authToken != null) {
        final response = await http.get(url, headers: headers);
        if(response.statusCode == 401 && !refreshed) {
          await refresh();
          return _getData(hook: hook, refreshed: true);
        }
        return jsonDecode(response.body);
      } else {
        final response = await http.get(url);
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {};
    }
  }

  // Funzione per fare POST
  static Future<Map<String,dynamic>> _postData({hook = String, parameters = Map<String, String>, refreshed = false}) async {
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    // The URL where you want to send the POST request
    final url = Uri.parse(testMode ? "$_TESTURL/$hook" : "$_PRODURL/$hook");
    try {
      if(authToken != null) {
        final response = await http.post(url, body: jsonEncode(parameters), headers: headers);
        print(response.body);
        print(response.statusCode);
        if(response.statusCode == 401 && !refreshed) {
          await refresh();
          return _postData(hook: hook, parameters: parameters, refreshed: true);
        }
        return jsonDecode(response.body);
      }
      else {
        final response = await http.post(url, body: jsonEncode(parameters));
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {};
    }
  }
}