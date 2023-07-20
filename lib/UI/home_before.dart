import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/UI/utilities/app_bar.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/rounded_container.dart';
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
          preferredSize: const Size.fromHeight(100.0), // here the desired height
          child: SmartVillageAppBar(background: Theme.of(context).colorScheme.background,)
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  ],
                ),
              ),
              const SizedBox(height: 40,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SmartVillageButton(
                  text: "Accedi",
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    //TODO: LOADING
                    print(await APIManager.auth(
                      email: _emailTextController.text.trim(),
                      password: _passwordTextController.text.trim()
                    ));
                  },
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}