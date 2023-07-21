import 'package:flutter/cupertino.dart';

class ErrorManager {
  static const String ERROR_UNKOWN = "error_Unknown";
  static const String ERROR_ACCOUNT_NOT_EXISTS = "error_AccountNotExists";
  static const String ERROR_EMAIL_REQUIRED = "error_EmailRequired";
  static const String ERROR_PASSWORD_REQUIRED = "error_PasswordRequired";

  static void showError(BuildContext context, String type) {
    switch(type) {
      case ERROR_EMAIL_REQUIRED:
        _noEmailError(context);
        break;
      case ERROR_PASSWORD_REQUIRED:
        _noPasswordError(context);
        break;
      case ERROR_ACCOUNT_NOT_EXISTS:
        _noAccountError(context);
        break;
      default:
        _defaultError(context);
        break;
    }
  }

  static void _noAccountError(BuildContext context) {
    _showSimpleErrorDialog(context, "Purtroppo non è stato trovato un account con queste credenziali.\n"
        "Per poter utilizzare Smart Village, è necessario contattare il proprio medico di base per procedere con la registrazione.\n\n"
        "Per favore, contatta il tuo medico di base e, se convenzionato, procedi con la registrazione al servizio.");
  }

  static void _noEmailError(BuildContext context) {
    _showSimpleErrorDialog(context, "Per favore, inserisci la tua email per procedere con il login.");
  }

  static void _noPasswordError(BuildContext context) {
    _showSimpleErrorDialog(context, "Per favore, inserisci la password per procedere con il login.");
  }

  static void _defaultError(BuildContext context) {
    _showSimpleErrorDialog(context, "È avvenuto un errore imprevisto. Per favore, riprova più tardi.");
  }

  static void _showSimpleErrorDialog(BuildContext context, String text) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Attenzione'),
        content: Text(text),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}