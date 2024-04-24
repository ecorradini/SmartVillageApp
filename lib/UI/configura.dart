import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/UI/utilities/rounded_container.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';

import '../API/health/health_manager.dart';
import '../API/mosaico/mosaico_manager.dart';
import '../API/mosaico/mosaico_user.dart';

//ignore: must_be_immutable
class Configura extends StatefulWidget {
  MosaicoUser mosaicoUser;
  MosaicoManager mosaicoManager;
  HealthManager healthManager;
  Configura({super.key, required this.mosaicoUser, required this.mosaicoManager, required this.healthManager});

  @override
  ConfiguraState createState() => ConfiguraState();
}

class ConfiguraState extends State<Configura> {
  late Future<PackageInfo> packageInfo;

  @override
  void initState() {
    packageInfo = PackageInfo.fromPlatform();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return SmartVillageScaffold(
      appBarTitle: "Configura",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoundedContainer(
                widgets: [
                  FutureBuilder(
                      future: packageInfo,
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return Text("Versione app: ${snapshot.data!.version}", style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onTertiary));
                        } else {
                          return const Text("Versione app: ", style: TextStyle(fontSize: 17));
                        }
                      }
                  ),
                  if (!widget.mosaicoUser.isLogged() || (widget.mosaicoUser.isLogged() && MosaicoManager.testMode)) Row(
                    children: [
                      Text("Modalità di test", style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onTertiary)),
                      const Spacer(),
                      CupertinoSwitch(
                        // This bool value toggles the switch.
                        value: MosaicoManager.testMode,
                        trackColor: CupertinoColors.lightBackgroundGray,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (bool? value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            MosaicoManager.testMode = value ?? false;
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setBool("testMode", value ?? false);
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  AutoSizeText(maxLines: 1, "Visualizza i Termini e Condizioni di utilizzo", textAlign: TextAlign.start, style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                  AutoSizeText(maxLines: 1, "Visualizza la Politica della Privacy", textAlign: TextAlign.start, style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                ]
            ),
            const Spacer(),
            /*if(Utente.logged) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SmartVillageButton(
                text: "Esci dall'app",
                onPressed: () async {
                  EasyLoading.show();
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _logout();
                  EasyLoading.dismiss();
                  if(context.mounted) Phoenix.rebirth(context);
                },
                color: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
              ),
            ),
            const SizedBox(height: 10,),*/
            /*if(Utente.logged) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SmartVillageButton(
                text: "Elimina account e dati",
                onPressed: () async {
                  EasyLoading.show();
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _logout();
                  EasyLoading.dismiss();
                  if(context.mounted) Phoenix.rebirth(context);
                },
                color: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
              ),
            ),*/
            const SizedBox(height: 40,)
          ],
        ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
    prefs.remove("password");
    prefs.remove("loggedFromTest");
    prefs.remove("healthSync");
    prefs.remove("autoSync");
    prefs.remove("logged");
    //widget.healthManager.revokePermissions();
  }
}