import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'error_manager.dart';

class MosaicoManager {

  static String prodUrl = "";
  static String testUrl = "";
  static bool testMode = false;
  bool healthSync = false;
  bool autoSync = true;
  static String? authToken;
  static String? refreshToken;

  static String get baseUrl => testMode ? testUrl : prodUrl;

  ///Load from SharedPreferences
  void loadFromPreferences(SharedPreferences prefs) {
    testMode = prefs.getBool("testMode") ?? false;
    healthSync = prefs.getBool("healthSync") ?? false;
    autoSync = prefs.getBool("autoSync") ?? true;
  }

  static Map<String, String> get headers => {
    if(MosaicoManager.authToken != null) 'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };

  /// Authenticate user with email and password.
  /// Returns a map with authToken and refreshToken if successful.
  Future<Map<String, String>> authenticate({required String email, required String password}) async {
    try {
      final response = await postData(
        endpoint: "/auth",
        parameters: {"email": email, "pwd": password},
      );
      if (response.containsKey("data")) {
        MosaicoManager.authToken = response["data"]["token"];
        MosaicoManager.refreshToken = response["data"]["refreshToken"];
        return {
          "authToken": MosaicoManager.authToken!,
          "refreshToken": MosaicoManager.refreshToken!,
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
  Future<void> refreshAuthToken() async {
    try {
      final url = Uri.parse("$baseUrl/auth/refresh");
      final response = await http.get(url, headers: headers);
      final res = jsonDecode(response.body);
      if (res.containsKey("data")) {
        MosaicoManager.authToken = res["data"]["token"];
      }
    } catch (_) {}
  }

  /// Generic POST request method.
  Future<Map<String, dynamic>> postData({
    required String endpoint,
    required Map<String, dynamic> parameters,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: MosaicoManager.headers,
      body: jsonEncode(parameters),
    );
    print(response.body);
    try {
      return jsonDecode(response.body);
    } on Exception catch(_) {
      return {
        "error": response.body,
      };
    }
  }

  /// Generic GET request method
  Future<Map<String,dynamic>> getData({
    required String endpoint,
    bool refreshed = false
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.get(
      url,
      headers: MosaicoManager.headers,
    );
    if(response.statusCode == 401 && !refreshed) {
      await refreshAuthToken();
      return getData(endpoint: endpoint, refreshed: true);
    }
    else {
      try {
        return jsonDecode(response.body);
      } on Exception catch(_) {
        return {
          "error": response.body,
        };
      }
    }
  }
}