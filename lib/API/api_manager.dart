import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/user.dart';

import '../UI/utilities/error_manager.dart';

class APIManager {
  static const String _PRODURL = "https://services.mosaicoproject.it/api/v2";
  static const String _TESTURL = "https://test-services.mosaicoproject.it/api/v2";

  static bool testMode = false;
  static bool healthSync = false;
  static bool autoSync = true;
  static String? authToken;

  static Future<String> auth({email = String, password = String}) async {
    Map<String,dynamic> res = await _postData(
      parameters: {
        "email": email,
        "pwd": password
      },
      hook: "auth"
    );
    if(res.containsKey("data")) {
      return res["data"]["token"];
    }
    else if(res.containsKey("errors")) {
      return "error_${res["errors"]![0]["type"] ?? "Unknown"}";
    }
    else {
      return ErrorManager.ERROR_UNKOWN;
    }
  }

  static Future<String> getPatientsList() async {
    Map<String,dynamic> res = await _getData(hook: "patients");
    return jsonEncode(res);
  }

  static Future<bool> login({email = String, password = String, codiceFiscale = String, prefs = SharedPreferences, context = BuildContext}) async {
    String result = await auth(
        email: email,
        password: password
    );
    if(result.contains("error_")) {
      if (context.mounted) ErrorManager.showError(context, result);
      return false;
    } else {
      authToken = result;
      String patientRes = await getPatient(codiceFiscale);
      if(patientRes.contains("error_")) {
        if (context.mounted) ErrorManager.showError(context, patientRes);
        return false;
      } else {
        Map<String,dynamic> patientResDict = jsonDecode(patientRes);
        Utente.nome = patientResDict["data"]!["name"];
        Utente.cognome = patientResDict["data"]!["surname"];
        Utente.dataNascita = patientResDict["data"]!["dateOfBirth"];
        Utente.genere = patientResDict["data"]!["genre"]!["id"];
        Utente.codiceEsenzione = patientResDict["data"]!["exemptionCode"];
        Utente.stato = patientResDict["status"];
        Utente.created = patientResDict["created"];
        Utente.id = patientResDict["uuid"];
        Utente.pairingCode = patientResDict["data"]!["pairingCode"];
        Utente.pin = patientResDict["data"]!["pin"].toString();
        prefs.setString("email", email);
        prefs.setString("password", password);
        prefs.setString("codiceFiscale", codiceFiscale);
        prefs.setBool("loggedFromTest", testMode);
        return true;
      }
    }
  }

  static Future<String> getPatient(String codiceFiscale) async {
    Map<String,dynamic> res = await _getData(hook: "patients/fiscal/$codiceFiscale");
    if(res.containsKey("data")) {
      return jsonEncode(res);
    } else if(res.containsKey("errors")) {
      return "error_${res["errors"]![0]["TYPE"] ?? "Unknown"}";
    } else {
      return ErrorManager.ERROR_UNKOWN;
    }
  }

  //Funzione per fare GET
  static Future<Map<String,dynamic>> _getData({hook = String}) async {
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    final url = Uri.parse(testMode ? "$_TESTURL/$hook" : "$_PRODURL/$hook");
    try {
      if(authToken != null) {
        final response = await http.get(url, headers: headers);
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
  static Future<Map<String,dynamic>> _postData({hook = String, parameters = Map<String, String>}) async {
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    // The URL where you want to send the POST request
    final url = Uri.parse(testMode ? "$_TESTURL/$hook" : "$_PRODURL/$hook");
    try {
      if(authToken != null) {
        final response = await http.post(url, body: jsonEncode(parameters), headers: headers);
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