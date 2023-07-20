import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/UI/utilities/app_bar.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/rounded_container.dart';

class Configura extends StatefulWidget {
  const Configura({super.key});

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
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0), // here the desired height
          child: SmartVillageAppBar(title: "Configura",background: Theme.of(context).colorScheme.background,)
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoundedContainer(
                widgets: [
                  FutureBuilder(
                      future: packageInfo,
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return Text("Versione app: ${snapshot.data!.version}", style: TextStyle(fontSize: 17));
                        } else {
                          return const Text("Versione app: ", style: TextStyle(fontSize: 17));
                        }
                      }
                  ),
                  Row(
                    children: [
                      const Text("Modalità di test", style: TextStyle(fontSize: 17)),
                      const Spacer(),
                      CupertinoSwitch(
                        // This bool value toggles the switch.
                        value: APIManager.testMode,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (bool? value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            APIManager.testMode = value ?? false;
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setBool("testMode", value ?? false);
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  const Text("Visualizza i Termini e Condizioni di utilizzo", textAlign: TextAlign.start),
                  const Text("Visualizza la Politica della Privacy", textAlign: TextAlign.start,),
                ]
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SmartVillageButton(
                text: "Esci dall'app",
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                color: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SmartVillageButton(
                text: "Elimina account e dati",
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                color: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}