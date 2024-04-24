import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartvillage/API/mosaico/mosaico_user.dart';
import 'package:smartvillage/UI/utilities/rounded_container.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';

//ignore: must_be_immutable
class HomeAfter extends StatelessWidget {

  MosaicoUser user;
  HomeAfter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    DateTime created = DateFormat("MMMM, dd yyyy HH:mm:ssZ").parse(user.getCreated()!);
    String dataCreated = DateFormat("dd/MM/yyyy").format(created);
    return SmartVillageScaffold(
      smallBar: true,
        child: Stack(
          children: [
            const Image(image: AssetImage('assets/logo.png'), height: 190, width: 89),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100,),
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(left: 90),
                  child: FittedBox(
                    alignment: Alignment.bottomLeft,
                    child: AutoSizeText("${user.getNome()?.toUpperCase()} ${user.getCognome()?.toUpperCase()}", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary), maxLines: 1, textAlign: TextAlign.start,)
                  )
                ),
                const SizedBox(height: 5,),
                RoundedContainer(
                    widgets: [
                      AutoSizeText("CF: ${user.getCodiceFiscale()}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary), minFontSize: 19,),
                      AutoSizeText("${user.getEmail()}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary), maxLines: 1,)
                      //AutoSizeText("Data di nascita: $dataNascita", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary), minFontSize: 19,),
                      //AutoSizeText("Genere: ${Utente.genere}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary), minFontSize: 19,),
                      //AutoSizeText("Codice Esenzione: ${Utente.codiceEsenzione.isEmpty ? "Assente" : Utente.codiceEsenzione}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary), minFontSize: 19,),
                    ]
                ),
                const Spacer(),
                Text("Stato: ${user.getStato()}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                Text("Creato: $dataCreated", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                Text("ID: ${user.getId()}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                Text("Abilitato: ${user.getEnabledAccount()}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                //Text("Codice Pairing: ${Utente.pairingCode}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                //Text("PIN: ${Utente.pin}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                const SizedBox(height: 40,)
              ],
            ),
          ],
        )
    );
  }
}