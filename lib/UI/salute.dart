import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartvillage/API/health_manager.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/error_manager.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';

import '../API/api_manager.dart';

class Salute extends StatefulWidget {
  Salute({super.key});

  @override
  SaluteState createState() => SaluteState();
}

class SaluteState extends State<Salute> {

  bool healthSync = false;
  DateTime? lastMeasurementsUpload;

  @override
  void initState() {
    healthSync = APIManager.healthSync;
    lastMeasurementsUpload = HealthManager.lastMeasurementsUpload;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartVillageScaffold(
      appBarTitle: "Salute",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Image(image: AssetImage('assets/apple_health_icon.png'), width: 50,),
                const SizedBox(width: 8,),
                AutoSizeText("Funziona con l'app Salute", maxLines: 1, style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold), minFontSize: 20,),
              ],
            ),
            const SizedBox(height: 12,),
            Text("Per poter funzionare, Smart Village necessita dell'accesso ai dati registrati nell'app Salute.", style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground), textAlign: TextAlign.justify,),
            const SizedBox(height: 20,),
            SmartVillageButton(
              text: "Sincronizza Dati",
              color: Theme.of(context).colorScheme.primary,
              enabled: !healthSync,
              big: false,
              onPressed: () async {
                EasyLoading.show();
                bool gotPermissions = await HealthManager.requestPermissions();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("healthSync", gotPermissions);
                APIManager.healthSync = gotPermissions;
                setState(() {
                  healthSync = gotPermissions;
                });
                EasyLoading.dismiss();
              },
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                Text("Sincronizzazione automatica", style: TextStyle(fontSize: 17, color: healthSync ? Theme.of(context).colorScheme.onBackground : CupertinoColors.inactiveGray)),
                const Spacer(),
                healthSync ? CupertinoSwitch(
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
              "Ultima sincronizzazione: ${lastMeasurementsUpload != null ? DateFormat("dd/MM/yyyy HH:mm:ss").format(lastMeasurementsUpload!) : "Nessuna"}",
              style: TextStyle(fontSize: 17, color: healthSync ? Theme.of(context).colorScheme.onBackground : CupertinoColors.inactiveGray), textAlign: TextAlign.center,),
            const SizedBox(height: 10,),
            SmartVillageButton(
              text: "Sincronizza manualmente",
              color: Theme.of(context).colorScheme.primary,
              big: false,
              onPressed: () async {
                EasyLoading.show();
                Map<String,dynamic> allReads = await HealthManager.readData();
                String uploadedId = await APIManager.uploadMeasurements(
                  valuesHR: allReads[APIManager.HEART_RATE_IDENTIFIER],
                  valuesBP: allReads[APIManager.BLOOD_PRESSURE_IDENTIFIER],
                  valuesOS: allReads[APIManager.OXYGEN_SATURATION_IDENTIFIER],
                  valuesBMI: allReads[APIManager.BODY_MASS_INDEX_IDENTIFIER],
                  valuesBFP: allReads[APIManager.BODY_FAT_PERCENTAGE_IDENTIFIER],
                  valuesLBM: allReads[APIManager.LEAN_BODY_MASS_IDENTIFIER],
                  valuesW: allReads[APIManager.WEIGHT_IDENTIFIER],
                  valuesECG: allReads[APIManager.ECG_IDENTIFIER],
                );
                if(!uploadedId.contains("error_")) {
                  APIManager.lastMeasurementID = uploadedId;
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("lastMeasurementID", uploadedId);
                  HealthManager.readLastDates();
                  setState(() {lastMeasurementsUpload = HealthManager.lastMeasurementsUpload;});
                  print("UPLOADED: ${await APIManager.getLastMeasurements()}");
                } else {
                  if(context.mounted) {
                    ErrorManager.uploadError(context);
                  }
                }
                EasyLoading.dismiss();
              },
              textColor: Theme.of(context).colorScheme.onPrimary,
              enabled: healthSync,
            ),
            const SizedBox(height: 30,)
          ],
        )
    );
  }
}