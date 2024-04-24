import 'dart:io' show Platform;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';

import '../API/phone/background_service_helper.dart';
import '../API/health/health_manager.dart';
import '../API/mosaico/mosaico_manager.dart';
import '../API/mosaico/mosaico_user.dart';

//ignore: must_be_immutable
class Salute extends StatefulWidget {
  MosaicoManager mosaicoManager;
  HealthManager healthManager;
  MosaicoUser mosaicoUser;
  BackgroundServiceHelper backgroundServiceHelper;
  Salute({super.key, required this.mosaicoManager, required this.healthManager, required this.mosaicoUser, required this.backgroundServiceHelper});

  @override
  SaluteState createState() => SaluteState();
}

class SaluteState extends State<Salute> {

  final String _androidAppName = "Google Fit";
  final String _iOSAppName = "Salute";
  String appName = "";

  HealthManager? healthManager;
  MosaicoManager? mosaicoManager;

  @override
  void initState() {
    healthManager = widget.healthManager;
    mosaicoManager = widget.mosaicoManager;
    appName = Platform.isIOS ? _iOSAppName : _androidAppName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartVillageScaffold(
        appBarTitle: "Salute",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Platform.isIOS
                    ? const Image(image: AssetImage('assets/apple_health_icon.png'), width: 35)
                    : const Image(image: AssetImage('assets/gfit_icon.png'), width: 35),
                const SizedBox(width: 8), // Provides space between the image and the text
                Flexible( // Use Flexible here for the text widget
                  child: AutoSizeText(
                    "Funziona con l'app $appName",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 18, // Minimum font size
                    maxFontSize: 36, // Maximum font size, adjust based on your needs
                    stepGranularity: 1,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12,),
            Text("Per poter funzionare, Smart Village necessita dell'accesso ai dati registrati nell'app $appName.", style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onBackground), textAlign: TextAlign.justify,),
            const SizedBox(height: 20,),
            SmartVillageButton(
              text: "Sincronizza Dati",
              color: Theme.of(context).colorScheme.primary,
              enabled: !(mosaicoManager?.healthSync ?? false),
              big: false,
              onPressed: () async {
                await EasyLoading.show();
                bool gotPermissions = await healthManager?.requestPermissions() ?? false;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("healthSync", gotPermissions);
                mosaicoManager?.healthSync = gotPermissions;
                setState(() {
                  mosaicoManager?.healthSync = gotPermissions;
                });
                if(!widget.backgroundServiceHelper.enabled) {
                  widget.backgroundServiceHelper.enableBackgroundService();
                }
                await EasyLoading.dismiss();
              },
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                AutoSizeText("Sincronizzazione automatica", style: TextStyle(color: (mosaicoManager?.healthSync ?? false) ? Theme.of(context).colorScheme.onBackground : CupertinoColors.inactiveGray)),
                const Spacer(),
                (mosaicoManager?.healthSync ?? false) ? CupertinoSwitch(
                  // This bool value toggles the switch.
                  value: mosaicoManager?.autoSync ?? false,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool? value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      mosaicoManager?.autoSync = value ?? false;
                      if((value ?? false) && !widget.backgroundServiceHelper.enabled) {
                        widget.backgroundServiceHelper.enableBackgroundService();
                      } else {
                        widget.backgroundServiceHelper.stopService();
                      }
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool("autoSync", value ?? false);
                      });
                    });
                  },
                ) : IgnorePointer(
                  ignoring: true,
                  child: CupertinoSwitch(
                    // This bool value toggles the switch.
                    value: false,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: null,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AutoSizeText(
              maxLines: 1,
              healthManager?.lastMeasurementsUpload != null ?
              "Ultima sincronizzazione: ${DateFormat("dd/MM/yyyy HH:mm:ss").format(healthManager?.lastMeasurementsUpload ?? DateTime.now())}" :
              "Ultima sincronizzazione: nessuna",
              style: TextStyle(fontSize: 17, color: (mosaicoManager?.healthSync ?? false) ? Theme.of(context).colorScheme.onBackground : CupertinoColors.inactiveGray), textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10,),
            SmartVillageButton(
              text: "Sincronizza manualmente",
              color: Theme.of(context).colorScheme.primary,
              big: false,
              onPressed: () async {
                EasyLoading.show();
                await healthManager?.completeUpload(widget.mosaicoUser.getCodiceFiscale()!);
                healthManager?.setLastUploadDateFromMosaico().then((value) { setState((){}); });
                EasyLoading.dismiss();
              },
              textColor: Theme.of(context).colorScheme.onPrimary,
              enabled: mosaicoManager?.healthSync ?? false,
            ),
            const SizedBox(height: 30,)
          ],
        )
    );
  }
}