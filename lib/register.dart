import 'dart:math';
import 'dart:typed_data';

import 'package:dstate/buy_sell.dart';
import 'package:dstate/rent.dart';
import 'package:dstate/tokenize_building.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';
//web3
import 'package:dstate/metamask_not_web.dart' if (dart.library.js) 'package:dstate/metamask_web.dart';
import 'package:dstate/transaction_sender.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:dart_web3/dart_web3.dart';
import 'package:convert/convert.dart';

import 'menu.dart';



class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.title, required this.provider, required this.localIp, required this.accountAddress}) : super(key: key);


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final EthereumWalletConnectProvider provider;
  final String localIp;
  final String accountAddress;





  @override
  State<RegisterPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RegisterPage> {
  bool uiMetamaskConnected = false;
  final emailController = TextEditingController();
  final usernameController = TextEditingController();

  int _counter = 0;
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final buildingNameController = TextEditingController();
  final buildingAddressController = TextEditingController();
  String authToken = "";


  Future<Response> sendPost(String publicAddress, String email, String username) {
    return post(
      Uri.parse('http://' + widget.localIp + ':3001/users'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'publicAddress': publicAddress,
        'email': email,
        'userName': username,
      }),
    );
    //CHANGE TO JSON CALL
  }

  Future<Response> getJWT(String publicAddress, String signature) {
    print(publicAddress);
    return post(
      Uri.parse('http://' + widget.localIp + ':3001/auth'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'publicAddress': publicAddress,
        'signature': signature,
      }),
    );
    //CHANGE TO JSON CALL
  }

  //Connect to Wallet
  //TODO: Make walletConnect work if metamask is already open ?
  _walletConnect2() async {
    //Wallet Connect Mobile
    if(Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android) {
      var user;
      Response response2 = await sendPost(widget.accountAddress, emailController.text, usernameController.text);
      Map<String, dynamic> decoded2 =json.decode(response2.body);
      user = decoded2["user"];
      print("first time");



      String nonce = user["nonce"].toString();
      String msg = "I am signing my one-time nonce: " + nonce;//I am signing my one-time nonce: ${user.nonce}
      //Shout-out to HaoCherHong for finding a fix for this and adding personalSign to the walletconnect_dart library :)
      String signature = await widget.provider.personalSign(message: msg, address: widget.accountAddress, password: "test password");

      print(signature);
      print(widget.accountAddress);
      //Response jwtResponse = await getJWT(accountAddress, signature);
      //!!!Response jwtResponse = await getJWT(accountAddress, "0x78464efcef0520455a04bebd120d6f26cc6bcdd35a1bfe670eaa9d5d3161cab6390acc382ac7d76aa0579ccf568113c900be1ed77d417f235a8b3b8807fc31f71c");
      Response jwtResponse = await getJWT(widget.accountAddress, signature);
      Map<String, dynamic> jwtDecoded =json.decode(jwtResponse.body);

      authToken = jwtDecoded["accessToken"];
      print(authToken);
      setState(() {
        uiMetamaskConnected = true;
      });




      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {

        return MenuPage(title: "Dstate", provider: widget.provider, authToken: authToken, localIp: widget.localIp, accountAddress: widget.accountAddress);

      }));







      //Map<String, dynamic>.from(decoded);

    }
    //Wallet Connect Web
    else {

        var user;
        Response response2 = await sendPost(widget.accountAddress, emailController.text, usernameController.text);
        Map<String, dynamic> decoded2 =json.decode(response2.body);
        user = decoded2["user"];




      //\x19Ethereum Signed Message:\n1h

      //String signature = await provider.sign(message: "0x5C783139457468657265756D205369676E6564204D6573736167653A5C6E3168", address: accountAddress);

      //print(signature);
      //TODO: send signature to backend
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {

        return MenuPage(title: "Dstate", provider: widget.provider, authToken: authToken, localIp: widget.localIp, accountAddress: widget.accountAddress);

      }));

    }
  }






  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () async => _walletConnect2(),
                child: const Text('Register'),
              ),
            ),

          ],

        ),
      ),


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}