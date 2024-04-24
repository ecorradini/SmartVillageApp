import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/mosaico/mosaico_user.dart';

import 'mosaico_manager.dart';

class MosaicoUserManager extends MosaicoManager {

  Future<String> _getCurrentUser() async {
    Map<String,dynamic> res = await getData(endpoint: "/auth/user");
    return jsonEncode(res);
  }

  Future<MosaicoUser?> login({email = String, password = String, prefs = SharedPreferences}) async {
    //Autentico
    Map<String,String> result = await authenticate(
        email: email,
        password: password
    );
    // Errore
    if(result.containsKey("error")) {
      return null;
    } else {
      // È andato tutto bene
      String userRes = await _getCurrentUser();
      //NON ho trovato l'utente
      if(userRes.contains("error_")) {
        //if (context.mounted) ErrorManager.showError(context, userRes);
        return null;
      } else {
        // È andato tutto bene
        Map<String,dynamic> userResDict = jsonDecode(userRes);
        if(userResDict.containsKey("data")) {
          prefs.setString("email", email);
          prefs.setString("password", password);
          prefs.setBool("loggedFromTest", MosaicoManager.testMode);
          MosaicoUser user = MosaicoUser.fromMosaicoDict(userResDict);
          user.setLogged();
          return user;
        } else {
          return null;
        }
      }
    }
  }
}