import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/user.dart';

import '../UI/utilities/error_manager.dart';

class APIManager {
  /// IDENTIFIERS IN MOSAICO
  static const String BLOOD_PRESSURE_IDENTIFIER = "_BloodPressure";
  static const String HEART_RATE_IDENTIFIER = "_HeartRate";
  static const String HEART_RATE_AW_IDENTIFIER = "_HeartRateAW";
  static const String OXYGEN_SATURATION_IDENTIFIER = "_OxygenSaturation";
  static const String BODY_MASS_INDEX_IDENTIFIER = "_BMI";
  static const String LEAN_BODY_MASS_IDENTIFIER = "_LBM";
  static const String BODY_FAT_PERCENTAGE = "_FBM";
  static const String WEIGHT_IDENTIFIER = "_Weight";
  static const String ECG_IDENTIFIER = "_ECG";

  static const String _authEndpoint = "/auth";
  static const String _refreshEndpoint = "/auth/refresh";

  static String prodUrl = "";
  static String testUrl = "";
  static bool testMode = false;
  static bool healthSync = false;
  static bool autoSync = true;
  static String? authToken;
  static String? refreshToken;

  static String get _baseUrl => testMode ? testUrl : prodUrl;

  /// Headers used in requests.
  static Map<String, String> get _headers => {
    if(authToken != null) 'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };

  /// Authenticate user with email and password.
  /// Returns a map with authToken and refreshToken if successful.
  static Future<Map<String, String>> authenticate({required String email, required String password}) async {
    try {
      final response = await _postData(
        endpoint: _authEndpoint,
        parameters: {"email": email, "pwd": password},
      );
      print(response);
      if (response.containsKey("data")) {
        return {
          "authToken": response["data"]["token"],
          "refreshToken": response["data"]["refreshToken"],
        };
      } else if (response.containsKey("error")) {
        return {"error": response["error"]};
      } else {
        return {"error": ErrorManager.ERROR_UNKOWN};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Refresh authentication token.
  static Future<void> refreshAuthToken() async {
    try {
      final url = Uri.parse("$_baseUrl$_refreshEndpoint");
      final response = await http.get(url, headers: _headers);
      final res = jsonDecode(response.body);
      if (res.containsKey("data")) {
        authToken = res["data"]["token"];
      }
    } catch (e) {
      print("Error refreshing token: $e");
    }
  }

  /// Generic POST request method.
  static Future<Map<String, dynamic>> _postData({
    required String endpoint,
    required Map<String, dynamic> parameters,
  }) async {
    final url = Uri.parse("$_baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(parameters),
    );
    return jsonDecode(response.body);
  }

  /// Generic GET request method
  static Future<Map<String,dynamic>> _getData({
    required String endpoint,
    bool refreshed = false
  }) async {
    final url = Uri.parse("$_baseUrl$endpoint");
    final response = await http.get(
      url,
      headers: _headers,
    );
    if(response.statusCode == 401 && !refreshed) {
      await refreshAuthToken();
      return _getData(endpoint: endpoint, refreshed: true);
    }
    else {
      return jsonDecode(response.body);
    }
  }

  /// Get current information on user
  static Future<String> _getCurrentUser() async {
    Map<String,dynamic> res = await _getData(endpoint: "/auth/user");
    return jsonEncode(res);
  }

  /// User login with email and password
  static Future<bool> login({email = String, password = String, prefs = SharedPreferences, context = BuildContext}) async {
    //Autentico
    Map<String,String> result = await authenticate(
        email: email,
        password: password
    );
    // Errore
    if(result.containsKey("error")) {
      if (context.mounted) ErrorManager.showError(context, result["error"]!);
      return false;
    } else {
      // È andato tutto bene
      authToken = result["authToken"];
      refreshToken = result["refreshToken"];
      String userRes = await _getCurrentUser();
      //NON ho trovato l'utente
      if(userRes.contains("error_")) {
        if (context.mounted) ErrorManager.showError(context, userRes);
        return false;
      } else {
        // È andato tutto bene
        Map<String,dynamic> userResDict = jsonDecode(userRes);
        Utente.nome = userResDict["data"]!["name"];
        Utente.cognome = userResDict["data"]!["surname"];
        Utente.email = userResDict["data"]!["account"]!["email"];
        Utente.stato = userResDict["status"];
        Utente.created = userResDict["created"];
        Utente.id = userResDict["uuid"];
        Utente.enabledAccount = userResDict["data"]!["account"]!["enabled"].toString();
        Utente.codiceFiscale = userResDict["data"]!["fiscalCode"].toString();
        prefs.setString("email", email);
        prefs.setString("password", password);
        prefs.setBool("loggedFromTest", testMode);
        return true;
      }
    }
  }

  /// Get the last date in Mosaico of measurement dataType
  static Future<DateTime> getLastMeasurementDate(String dataType) async {
    Map<String,dynamic> last10 = await _getData(endpoint: "/measurements/medical-data/$dataType");
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

  /// Upload ECGs values
  static Future<void> uploadECGs({List<Map<String,dynamic>>? valuesECG}) async {
    if(valuesECG != null && valuesECG.isNotEmpty) {
      for (Map<String, dynamic> data0 in valuesECG) {
        Map<String, dynamic> parameters = {
          "patient": {
            "fiscalCode": Utente.codiceFiscale
          },
          "data": {
            ECG_IDENTIFIER: [data0],
          },
        };
        await _postData(
            parameters: parameters,
            endpoint: "/measurements"
        );
      }
    }
  }

  /// Funzione per dividere una lista
  static List<List<T>> splitList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      var end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  /// Upload all measurements that are not ECGs
  static Future<void> uploadMeasurements({
    List<Map<String,dynamic>>? valuesHR,
    List<Map<String,dynamic>>? valuesHRAW,
    List<Map<String,dynamic>>? valuesBP,
    List<Map<String,dynamic>>? valuesOS,
    List<Map<String,dynamic>>? valuesBMI,
    List<Map<String,dynamic>>? valuesLBM,
    List<Map<String,dynamic>>? valuesBFP,
    List<Map<String,dynamic>>? valuesW})
  async {
    Map<String, dynamic> data = {
      if(valuesHR != null && valuesHR.isNotEmpty) HEART_RATE_IDENTIFIER: valuesHR,
      if(valuesHRAW != null && valuesHRAW.isNotEmpty) HEART_RATE_AW_IDENTIFIER: valuesHRAW,
      if(valuesBP != null && valuesBP.isNotEmpty) BLOOD_PRESSURE_IDENTIFIER: valuesBP,
      if(valuesOS != null && valuesOS.isNotEmpty) OXYGEN_SATURATION_IDENTIFIER: valuesOS,
      if(valuesBMI != null && valuesBMI.isNotEmpty) BODY_MASS_INDEX_IDENTIFIER: valuesBMI,
      if(valuesLBM != null && valuesLBM.isNotEmpty) LEAN_BODY_MASS_IDENTIFIER: valuesLBM,
      if(valuesBFP != null && valuesBFP.isNotEmpty) BODY_FAT_PERCENTAGE: valuesBFP,
      if(valuesW != null && valuesW.isNotEmpty) WEIGHT_IDENTIFIER: valuesW,
    };
    if(data.isNotEmpty) {
      for(String key in data.keys) {
        // Li spezzo se no impezzisce
        for(List<Map<String, dynamic>> chunk in splitList<Map<String, dynamic>>(data[key], 1000)) {
          Map<String, dynamic> parameters = {
            "patient": {
              "fiscalCode": Utente.codiceFiscale
            },
            "data": {
              key: chunk,
            },
          };
          Map<String, dynamic> res = await _postData(
              parameters: parameters,
              endpoint: "/measurements"
          );
          if (res.containsKey("data")) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("lastMeasurementsId", res["data"]["id"].toString());
          }
        }
      }
    }
  }
}