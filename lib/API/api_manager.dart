import 'dart:convert';

import 'package:http/http.dart' as http;

import '../UI/utilities/error_manager.dart';

class APIManager {
  static const String _PRODURL = "https://services.mosaicoproject.it/api/v2";
  static const String _TESTURL = "https://test-services.mosaicoproject.it/api/v2";

  static bool testMode = false;
  static String? authToken;

  static Future<String> auth({email = String, password = String}) async {
    Map<String,dynamic> res = await _postData(
      parameters: {
        "email": email,
        "pwd": password
      },
      hook: "auth"
    );
    if(res.containsKey("result")) {
      return res["result"]["authToken"];
    }
    else if(res.containsKey("errors")) {
      return "error_${res["errors"]![0]["type"] ?? "Unknown"}";
    }
    else {
      return ErrorManager.ERROR_UNKOWN;
    }
  }

  // Funzione per fare POST
  static Future<Map<String,dynamic>> _postData({hook = String, parameters = Map<String, String>}) async {
    // The URL where you want to send the POST request
    final url = Uri.parse(testMode ? "$_TESTURL/$hook" : "$_PRODURL/$hook");
    try {
      final response = await http.post(url, body: jsonEncode(parameters));
      return jsonDecode(response.body);
    } catch (e) {
      return {};
    }
  }
}