import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/mosaico/error_manager.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';
import 'package:smartvillage/UI/utilities/textfield.dart';

import '../API/mosaico/mosaico_user.dart';
import '../API/mosaico/user_manager.dart';

//ignore: must_be_immutable
class HomeBefore extends StatefulWidget {
  MosaicoUserManager mosaicoUserManager;
  MosaicoUser mosaicoUser;
  HomeBefore({super.key, required this.mosaicoUserManager, required this.mosaicoUser});

  @override
  HomeBeforeState createState() => HomeBeforeState();
}

class HomeBeforeState extends State<HomeBefore> {

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

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
                        MosaicoUser? logged = await widget.mosaicoUserManager.login(
                            email: _emailTextController.text.trim(),
                            password: _passwordTextController.text.trim(),
                            prefs: prefs
                        );
                        EasyLoading.dismiss();
                        if(logged != null) {
                          widget.mosaicoUser = logged;
                          if(context.mounted) {
                            Phoenix.rebirth(context);
                          }
                        } else {
                          ErrorManager.showError(context, ErrorManager.ERROR_ACCOUNT_NOT_EXISTS);
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