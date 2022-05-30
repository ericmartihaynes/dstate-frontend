import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class metamaskWidget{
   //bool isDialogShown = false;

  showWalletDialog(BuildContext context) {
    bool isDialogShown = true;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(

            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
            backgroundColor: Colors.white,
            title: const Text('Confirm Operation in Wallet',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              Center(child: Image.asset('assets/metamask.gif')),
            ],
          );
        }
    ).whenComplete(() => isDialogShown = false);
  }
}