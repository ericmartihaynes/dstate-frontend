import 'dart:math';
import 'dart:typed_data';

import 'package:dstate/buy_sell.dart';
import 'package:dstate/rent.dart';
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

import 'create_token.dart';


class TokenizePage extends StatefulWidget {
  const TokenizePage ({Key? key, required this.title, required this.provider, required this.authToken, required this.localIp, required this.accountAddress}) : super(key: key);


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final EthereumWalletConnectProvider provider;
  final String authToken;
  final String localIp;
  final String accountAddress;



  @override
  State<TokenizePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TokenizePage> {
  int _counter = 0;
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final buildingNameController = TextEditingController();
  final buildingAddressController = TextEditingController();
  String buildingId = "";

  void createBuilding(String buildingName, String buildingAddress) async {
    Response res = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_name': buildingName,
        'building_address': buildingAddress,
      }),
    );
    Map<String, dynamic> decoded =json.decode(res.body);
    buildingId = decoded["building"]["_id"];

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {

      return TokenPage(title: "Create Token", provider: widget.provider, authToken: widget.authToken, localIp: widget.localIp, buildingId: buildingId, accountAddress: widget.accountAddress);

    }));
  }



  Future<Response> fetchUsers(String publicAddress) {
    print(publicAddress);
    print("print1");
    return get(
      Uri.parse('http://' + widget.localIp + ':3001/users?publicAddress=' + publicAddress), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //CHANGE TO JSON CALL
  }

  Future<Response> sendPost(String publicAddress) {
    return post(
      Uri.parse('http://' + widget.localIp + ':3001/users'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'publicAddress': publicAddress,
        'email': "test2@test.com",
        'userName': "flutterTest2",
      }),
    );
    //CHANGE TO JSON CALL
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
                controller: buildingNameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Building Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: buildingAddressController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Building Address',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.lightGreen,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => createBuilding(buildingNameController.text, buildingAddressController.text),
                child: const Text('Create Building'),
              ),
            ),

          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
