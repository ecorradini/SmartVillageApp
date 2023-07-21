import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';

import '../API/api_manager.dart';

class Salute extends StatefulWidget {
  Salute({super.key});

  SaluteState createState() => SaluteState();
}

class SaluteState extends State<Salute> {
  @override
  Widget build(BuildContext context) {
    return SmartVillageScaffold(
      appBarTitle: "Salute",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image(image: AssetImage('assets/apple_health_icon.png'), width: 50,),
                SizedBox(width: 8,),
                Text("Funziona con l'app Salute", style: TextStyle(fontSize: 22),)
              ],
            ),
            const SizedBox(height: 12,),
            const Text("Per poter funzionare, Smart Village necessita dell'accesso ai dati registrati nell'app Salute.", style: TextStyle(fontSize: 18), textAlign: TextAlign.justify,),
            const SizedBox(height: 20,),
            SmartVillageButton(
              text: "Sincronizza Dati",
              color: Theme.of(context).colorScheme.primary,
              loading: false,
              big: false,
              onPressed: () { },
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                const Text("Sincronizzazione automatica", style: TextStyle(fontSize: 17)),
                const Spacer(),
                CupertinoSwitch(
                  // This bool value toggles the switch.
                  value: APIManager.autoSync,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool? value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      APIManager.autoSync = value ?? false;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool("autoSync", value ?? false);
                      });
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            const Text("Ultima sincronizzazione: ", style: TextStyle(fontSize: 17), textAlign: TextAlign.center,),
            const SizedBox(height: 10,),
            SmartVillageButton(
              text: "Sincronizza manualmente",
              color: Theme.of(context).colorScheme.primary,
              loading: false,
              big: false,
              onPressed: () { },
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 80,)
          ],
        )
    );
  }
}