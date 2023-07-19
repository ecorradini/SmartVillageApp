import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartvillage/UI/utilities/app_bar.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/textfield.dart';

class HomeBefore extends StatefulWidget {
  const HomeBefore({super.key});

  @override
  HomeBeforeState createState() => HomeBeforeState();
}

class HomeBeforeState extends State<HomeBefore> {

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _cfTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // here the desired height
        child: SmartVillageAppBar()
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 50, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Email", textAlign: TextAlign.start, style: TextStyle(fontSize: 17),),
            SmartVillageTextField(
              controller: _emailTextController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20,),
            const Text("Password", textAlign: TextAlign.start, style: TextStyle(fontSize: 17),),
            SmartVillageTextField(
              controller: _passwordTextController,
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
            const SizedBox(height: 20,),
            const Text("Codice Fiscale", textAlign: TextAlign.start, style: TextStyle(fontSize: 17),),
            SmartVillageTextField(
              controller: _cfTextController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SmartVillageButton(
                text: "Accedi",
                color: CupertinoColors.activeGreen,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                textColor: CupertinoColors.white,
              ),
            ),
            const Spacer(),
            const Text("Visualizza i Termini e Condizioni di utilizzo", textAlign: TextAlign.center,),
            const SizedBox(height: 8,),
            const Text("Visualizza la Politica della Privacy", textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}