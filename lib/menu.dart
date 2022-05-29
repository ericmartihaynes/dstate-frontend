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


class MenuPage extends StatefulWidget {
  const MenuPage ({Key? key, required this.title, required this.provider, required this.authToken, required this.localIp}) : super(key: key);


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



  @override
  State<MenuPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MenuPage> {
  int _counter = 0;
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final buildingNameController = TextEditingController();
  final buildingAddressController = TextEditingController();
  String accountAddress = "";
  String buildingId = "";
  //TODO Change ip

  //Send data to backend
  Future<Response> sendData(String name, double tokenAmount) {
    print(name + " " + tokenAmount.toString());
    return post(
      Uri.parse('http://' + widget.localIp + ':3001/building/deploy'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'initial_amount': tokenAmount.toInt().toString(),
        'symbol': "DST1",
        'building_id': buildingId,
        'building_name': 'Train Station',
        'building_address': 'Horsens',
        'rentPrice': 1000000000000000000,
        'depositPrice': 2000000000000000000,
        'remainingMonths': 7,
        'caretakerShare': 10,
        'caretaker': '0x7176bd09199068e21be4137d1630fb8712633445',
        'tenant': '0x7176bd09199068e21be4137d1630fb8712633445'
      }), //TODO: Add fields for this data ^ and change hardcoded
    );
    //CHANGE TO JSON CALL
  }

  beforeBuySell() async {

    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': "628b802a01929414d3cfaab8",
        'tokenAmount': 1,
        'tokenAddress': "0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f",

      }),
    );

    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String price = (double.parse(decodedRsp["price"])  / (pow(10,18)) ).toString();

    /*Response rsp2 = await post(
      Uri.parse('http://' + localIp + ':3001/building/getPriceForTokens'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': "628b802a01929414d3cfaab8",
        'tokenAmount': 1,
        'tokenAddress': "0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f",

      }),
    );

    Map<String, dynamic> decodedRsp2 =json.decode(rsp.body);
    String price = (double.parse(decodedRsp2["price"])  / (pow(10,18)) ).toString();*/
    Navigator.push(context, MaterialPageRoute(builder: (context) {

      return BuySellPage(context: context,title: 'Buy / Sell', authToken: widget.authToken, localIp: widget.localIp,
          accountAddress: accountAddress, provider: widget.provider, currentPrice: price);

    }));
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
      drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
               DrawerHeader(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context), // Handle your on tap here.
                      icon: Icon(Icons.arrow_back),
                      iconSize: 40,
                    ),
                    Text('Dstate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 3,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.purple,
                ),

              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Colors.purple[200]),
                title: Text('Portfolio', style: TextStyle(color: Colors.purple[200])),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(Icons.location_city),
                title: const Text('Buildings'),
                onTap: () async { beforeBuySell(); },
              ),
              ListTile(
                leading: Icon(Icons.domain_add),
                title: const Text('Tokenize'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {

                return TokenizePage(title: "Tokenize", provider: widget.provider, authToken: widget.authToken, localIp: widget.localIp);

                })),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

          ],

        ),
      ),


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
