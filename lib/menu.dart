import 'dart:math';
import 'dart:typed_data';

import 'package:dstate/buy_sell.dart';
import 'package:dstate/rent.dart';
import 'package:dstate/tokenize_building.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';
//web3
import 'package:dstate/metamask_not_web.dart' if (dart.library.js) 'package:dstate/metamask_web.dart';
import 'package:dstate/transaction_sender.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:dart_web3/dart_web3.dart';
import 'package:convert/convert.dart';

import 'buildings.dart';


class MenuPage extends StatefulWidget {
  const MenuPage ({Key? key, required this.title, required this.provider, required this.authToken, required this.localIp, required this.accountAddress, required this.tokens, required this.ethBalance, required this.username}) : super(key: key);


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
  final List<Widget> tokens;
  final String ethBalance;
  final String username;



  @override
  State<MenuPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MenuPage> {
  int _counter = 0;
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final buildingNameController = TextEditingController();
  final buildingAddressController = TextEditingController();
  String buildingId2 = '62936fec385e672267bc77ee';


  MenuPage() {
    Widget personalCard;
    personalCard = Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shadowColor: Colors.deepPurple,
          elevation: 8,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepPurple],
                begin: Alignment.bottomRight,
                end: Alignment.topCenter,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 2.0, left: 2.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.account_circle,
                          size: 45,
                        ),
                      ),
                      Text(
                        widget.username,
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 2.0, left: 2.0),
                  child: Text(
                    widget.ethBalance + ' ETH',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 2.0, left: 2.0),
                  child: Text(
                    widget.accountAddress,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (widget.tokens.isEmpty || widget.tokens[0].runtimeType.toString() == "Padding") {
      widget.tokens.insert(0, personalCard);
    }
  }



  beforeBuildings(String tokenAddress) async {
    List<Widget> buildings = [];
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/approved'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    var list = decodedRsp["buildings"];
    Widget buildingCard;
    //String name;
    //String address;
    //String token = "";
    //String rent = "";
    //String buildingId;

    for(dynamic building in list) {
      print(building);
      final String name = building["name"];
      final String address = building["address"];
      final String buildingId = building["_id"];
      String token = "0x0000000000000000000000000000000000000000";
      String rent = "0x0000000000000000000000000000000000000000";
      try{ token = building["token_id"]["address"];} catch(e){} //TODO: maybe add diferent pictures
      try{ rent = building["rentContractAddress"];} catch(e){}
      buildingCard = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
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
                      onTap: () => beforeBuySell(token, rent, buildingId),
                    ),
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Text(
                      name,
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        address,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      token,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              ButtonBar()
            ],
          ),
        ),
      );
      buildings.add(buildingCard);
      dev.log(decodedRsp.toString());

    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {

      return BuildingsPage(title: "Dstate", provider: widget.provider, authToken: widget.authToken, localIp: widget.localIp, accountAddress: widget.accountAddress,buildings: buildings);

    }));
  }

  beforeBuySell(String _tokenAddress, String _rentAddress, String _buildingId) async {

    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': _buildingId,
        'tokenAmount': 1,
        'tokenAddress': _tokenAddress,

      }),
    );

    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String price = (double.parse(decodedRsp["price"])  / (pow(10,18)) ).toString();

    Response rsp2 = await get(
      Uri.parse('http://' + widget.localIp + ':3001/token/balanceOf?tokenAddress=' + _tokenAddress), //REMEMBER TO CHANGE IP ADDRESS
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
          accountAddress: widget.accountAddress, provider: widget.provider, currentPrice: price, currentTokenBalance: tokens, currentEthBalance: eth, buildingId: _buildingId, tokenAddress: _tokenAddress, rentAddress: _rentAddress);

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
    MenuPage();
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
                onTap: () async { beforeBuildings('0x06c6005575b12e691046DCD52CBD0e3e1A8FF9a4'); },
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
            itemCount: widget.tokens.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return widget.tokens[index];
            })
      ),


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}
