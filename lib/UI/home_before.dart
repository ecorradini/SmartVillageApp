import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartvillage/API/api_manager.dart';
import 'package:smartvillage/UI/utilities/button.dart';
import 'package:smartvillage/UI/utilities/error_manager.dart';
import 'package:smartvillage/UI/utilities/scaffold.dart';
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
    bool loading = false;

    return SmartVillageScaffold(
      loading: loading,
      smallBar: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Smart Village", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),),
            const Text("Inserisci le tue credenziali per continuare."),
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
                  const SizedBox(height: 10,),
                  SmartVillageTextFieldWithIcon(
                    icon: CupertinoIcons.creditcard,
                    controller: _cfTextController,
                    keyboardType: TextInputType.text,
                    placeholder: "Codice Fiscale",
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50,),
            SmartVillageButton(
              text: "Accedi",
              color: Theme.of(context).colorScheme.primary,
              loading: loading,
              big: true,
              onPressed: () async {
                setState(() {loading = true;});
                FocusManager.instance.primaryFocus?.unfocus();
                //TODO: LOADING
                String result = await APIManager.auth(
                    email: _emailTextController.text.trim(),
                    password: _passwordTextController.text.trim()
                );
                print("AUTH $result");
                if(result.contains("error_")) {
                  if (context.mounted) ErrorManager.showError(context, result);
                } else {
                  APIManager.authToken = result;
                }
                setState(() {loading = false;});
              },
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}