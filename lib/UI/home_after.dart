import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:smartvillage/API/user.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';

class HomeAfter extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DateTime birth = DateFormat("MMMM, dd yyyy HH:mm:ssZ").parse(Utente.dataNascita);
    DateTime created = DateFormat("MMMM, dd yyyy HH:mm:ssZ").parse(Utente.created);
    String dataNascita = DateFormat("dd/MM/yyyy").format(birth);
    String dataCreated = DateFormat("dd/MM/yyyy").format(created);
    return SmartVillageScaffold(
      appBarTitle: "Smart Village",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("${Utente.nome} ${Utente.cognome}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),),
          const SizedBox(height: 20,),
          Text("Data di nascita: $dataNascita", style: const TextStyle(fontSize: 17),),
          Text("Genere: ${Utente.genere}", style: const TextStyle(fontSize: 17),),
          Text("Codice Esenzione: ${Utente.codiceEsenzione.isEmpty ? "Assente" : Utente.codiceEsenzione}", style: const TextStyle(fontSize: 17),),
          const Spacer(),
          Text("Stato: ${Utente.stato}"),
          Text("Creato: $dataCreated"),
          Text("ID: ${Utente.id}"),
          Text("Codice Pairing: ${Utente.pairingCode}"),
          Text("PIN: ${Utente.pin}"),
          const SizedBox(height: 80,)
        ],
      ),
    );
  }
}