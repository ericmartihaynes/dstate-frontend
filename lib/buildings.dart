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


class BuildingsPage extends StatefulWidget {
  const BuildingsPage ({Key? key, required this.title, required this.provider, required this.authToken, required this.localIp, required this.accountAddress, required this.buildings}) : super(key: key);


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
  final List<Widget> buildings;




  @override
  State<BuildingsPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BuildingsPage> {
  int _counter = 0;
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final buildingNameController = TextEditingController();
  final buildingAddressController = TextEditingController();
  String buildingId2 = '62936fec385e672267bc77ee';



  beforeBuySell(String tokenAddress) async {

    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId2,
        'tokenAmount': 1,
        'tokenAddress': tokenAddress,

      }),
    );

    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String price = (double.parse(decodedRsp["price"])  / (pow(10,18)) ).toString();

    Response rsp2 = await get(
      Uri.parse('http://' + widget.localIp + ':3001/token/balanceOf?tokenAddress=' + tokenAddress), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
    );

    Map<String, dynamic> decodedRsp2 =json.decode(rsp2.body);
    String tokens = (decodedRsp2["balance"]).toString();

    Response rsp3 = await get(
      Uri.parse('http://' + widget.localIp + ':3001/token/balanceInEth'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },

    );
    print(rsp3.body);
    Map<String, dynamic> decodedRsp3 =json.decode(rsp3.body);
    String eth = (decodedRsp3["balance"]).toString();

    Navigator.push(context, MaterialPageRoute(builder: (context) {

      return BuySellPage(context: context,title: 'Buy / Sell', authToken: widget.authToken, localIp: widget.localIp,
          accountAddress: widget.accountAddress, provider: widget.provider, currentPrice: price, currentTokenBalance: tokens, currentEthBalance: eth, buildingId: buildingId2, tokenAddress: tokenAddress, rentAddress: '0x7aA7b5e70D361c3e1Fc9E24a841f1440276d0d74');

    }));
  }

  beforeMenu() {
    List<Widget> tokens = [];
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    /*Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {

      return MenuPage(title: "Dstate", provider: widget.provider, authToken: widget.authToken, localIp: widget.localIp, accountAddress: widget.accountAddress, tokens: tokens);

    }));*/
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
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Portfolio'),
              onTap: () {
                beforeMenu();
              },
            ),
            ListTile(
              leading: Icon(Icons.location_city, color: Colors.purple[200]),
              title: Text('Buildings', style: TextStyle(color: Colors.purple[200])),
              onTap: () async { },
            ),
            ListTile(
              leading: Icon(Icons.domain_add),
              title: const Text('Tokenize'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {

                return TokenizePage(title: "Tokenize", provider: widget.provider, authToken: widget.authToken, localIp: widget.localIp, accountAddress: widget.accountAddress);

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
          child: new ListView.builder(
              itemCount: widget.buildings.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return widget.buildings[index];
              }) /*ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.deepOrange,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => beforeBuySell('0x06c6005575b12e691046DCD52CBD0e3e1A8FF9a4'),
                child: const Text('Buy / Sell'),
              ),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Ink.image(
                        image: NetworkImage(
                          'http://placeimg.com/640/480/arch',
                        ),
                        child: InkWell(
                          onTap: () {},
                        ),
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        left: 16,
                        child: Text(
                          'Building 1',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            backgroundColor: Colors.grey.withOpacity(0.25),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(16).copyWith(bottom: 0),
                    child: Text(
                      'The cat is the only domesticated species in the family Felidae and is often referred to as the domestic cat to distinguish it from the wild members of the family.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ButtonBar()
                ],
              ),
            ),

          ],

        ),*/
      ),


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
