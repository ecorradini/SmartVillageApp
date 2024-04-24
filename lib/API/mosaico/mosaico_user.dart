import 'package:shared_preferences/shared_preferences.dart';

///Classe che rappresenta un utente mosaico
class MosaicoUser {
  String? _nome;
  String? _cognome;
  String? _email;
  String? _password;
  String? _stato;
  String? _created;
  String? _id;
  String? _enabledAccount;
  String? _codiceFiscale;
  bool _logged = false;
  bool _loggedFromTest = false;

  MosaicoUser({String? nome,
    String? cognome,
    String? email,
    String? password,
    String? stato,
    String? created,
    String? id,
    String? enabledAccount,
    String? codiceFiscale}) :
      _nome = nome,
      _cognome = cognome,
      _email = email,
      _password = password,
      _stato = stato,
      _created = created,
      _id = id,
      _enabledAccount = enabledAccount,
      _codiceFiscale = codiceFiscale;

  String? getNome() { return _nome; }

  String? getCognome() { return _cognome; }

  String? getStato() { return _stato; }

  String? getCreated() { return _created; }

  String? getId() { return _id; }

  String? getEnabledAccount() { return _enabledAccount; }

  void setLogged() { _logged = true; }

  bool isLogged() { return _logged; }

  String? getEmail() { return _email; }

  String? getPassword() { return _password; }

  String? getCodiceFiscale() { return _codiceFiscale; }

  static MosaicoUser? loadFromPrefs(SharedPreferences prefs) {
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");
    if(email != null && password != null) {
      return MosaicoUser(email: email, password: password);
    } else {
      return null;
    }
  }

  bool hasEmailAndPassword() {
    return _email != null && _password != null;
  }

  ///Factory Method per istanziare da dict di Mosaico
  static MosaicoUser fromMosaicoDict(Map<String,dynamic> userResDict) {
    return MosaicoUser(
        nome: userResDict["data"]!["name"],
        cognome: userResDict["data"]!["surname"],
        email: userResDict["data"]!["account"]!["email"],
        stato: userResDict["status"],
        created: userResDict["created"],
        id: userResDict["uuid"],
        enabledAccount: userResDict["data"]!["account"]!["enabled"].toString(),
        codiceFiscale: userResDict["data"]!["fiscalCode"].toString()
    );
  }
}