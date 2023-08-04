import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/API/background_service_helper.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';
import 'package:smartvillage/UI/utilities/textfield.dart';

class HomeBefore extends StatefulWidget {
  const HomeBefore({super.key});

  @override
  HomeBeforeState createState() => HomeBeforeState();
}

class HomeBeforeState extends State<HomeBefore> {

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  //final _cfTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return SmartVillageScaffold(
        smallBar: true,
        child: Stack(
          children: [
            const Image(image: AssetImage('assets/logo.png'), height: 200, width: 93),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 90,),
                  Padding(
                    padding: const EdgeInsets.only(left: 91),
                    child: FittedBox(
                      child: AutoSizeText("SMART VILLAGE", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary), textAlign: TextAlign.start,),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 91),
                    child: AutoSizeText("Inserisci le tue credenziali per continuare.",  style: TextStyle(color: Theme.of(context).colorScheme.onBackground), textAlign: TextAlign.start, maxLines: 1,),
                  ),
                  const SizedBox(height: 20,),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SmartVillageTextFieldWithIcon(
                          icon: CupertinoIcons.envelope,
                          controller: _emailTextController,
                          keyboardType: TextInputType.emailAddress,
                          placeholder: "Email",
                          context: context,
                        ),
                        const SizedBox(height: 10,),
                        SmartVillageTextFieldWithIcon(
                          icon: CupertinoIcons.padlock,
                          controller: _passwordTextController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          placeholder: "Password",
                          context: context,
                        ),
                        /*const SizedBox(height: 10,),
                        SmartVillageTextFieldWithIcon(
                          icon: CupertinoIcons.creditcard,
                          controller: _cfTextController,
                          keyboardType: TextInputType.text,
                          placeholder: "Codice Fiscale",
                          context: context,
                        ),*/
                      ],
                    ),
                  ),
                  const SizedBox(height: 40,),
                  SmartVillageButton(
                    text: "Accedi",
                    color: Theme.of(context).colorScheme.primary,
                    big: true,
                    onPressed: () async {
                      EasyLoading.show();
                      FocusManager.instance.primaryFocus?.unfocus();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      if(context.mounted) {
                        bool logged = await APIManager.login(
                            email: _emailTextController.text.trim(),
                            password: _passwordTextController.text.trim(),
                            //codiceFiscale: _cfTextController.text.trim(),
                            prefs: prefs,
                            context: context
                        );
                        EasyLoading.dismiss();
                        if (logged && context.mounted) {
                          if(APIManager.autoSync) {
                            BackgroundServiceHelper.enableBackgroundService();
                          }
                          Phoenix.rebirth(context);
                        }
                      }
                    },
                    textColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}