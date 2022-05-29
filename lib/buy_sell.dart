import 'dart:math';

import 'package:dstate/rent.dart';
import 'package:dstate/voting.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';

import 'package:dstate/buy_sell.dart';
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

final pricePerTokenController = TextEditingController();
final amountToSellController = TextEditingController();
final amountToBuyController = TextEditingController();
final amountToCancelController = TextEditingController();
const String tokenAddress = "0xSomethinghere";
int _selectedIndex = 0;



class BuySellPage extends StatefulWidget {
  const BuySellPage(
      {Key? key, required this.context, required this.title, required this.authToken, required this.localIp, required this.accountAddress, required this.provider, required this.currentPrice})
      : super(key: key);
  final BuildContext context;
  final String title;
  final String authToken;
  final String localIp;
  final String accountAddress;
  final EthereumWalletConnectProvider provider;
  final String currentPrice;

  @override
  State<BuySellPage> createState() => _MyHomePageState();
}
  //final int nonce = 31; //TODO get this from backend!!!!!!!!!!!!!!!!!
class _MyHomePageState extends State<BuySellPage> {

  void sellToken(double ethAmount, double tokenAmount, String buildingId, String tokenAddress) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/createSetPriceTransaction'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'tokenAmount': tokenAmount,
        'amountOfETH': ethAmount,
        'tokenAddress': tokenAddress,

      }),
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String data2 = decodedRsp["abi"];
    int nonce = int.parse(decodedRsp["nonce"].toString());
    data2 = data2.substring(2);
    const Utf8Encoder encoder = Utf8Encoder();
    List<int> value = hex.decode(data2);
    Uint8List encodedData = Uint8List.fromList(value);
    var tx;
    if(/*approved already*/true) {
      tx = await widget.provider.sendTransaction(from: widget.accountAddress,
          to: "0x392F7bAccBfE1324df91298ae9Ffc153111CED7c",
          data: encodedData,
          nonce: nonce,
          gas: 1500000); //TODO: test if stating gas is necessary
    }
    else{
      tx = await widget.provider.sendTransaction(from: widget.accountAddress,
          to: "0xe922E9152c588e9FCedDD239f6AAF19B2eEC0d6f",
          data: encodedData,
          gas: 1500000);
    }
    print("Sold!");
    print(tx);
  }

  void buyToken(double tokenAmount, String buildingId, String tokenAddress) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'tokenAmount': tokenAmount,
        'tokenAddress': tokenAddress,

      }),
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String price = decodedRsp["price"];

    Response rsp2 = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/createBuyTokenTransaction'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'tokenAmount': tokenAmount,
        'promisedPrice': price,
        'tokenAddress': tokenAddress,

      }),
    );
    Map<String, dynamic> decodedRsp2 =json.decode(rsp2.body);
    String data2 = decodedRsp2["abi"];
    int nonce = int.parse(decodedRsp["nonce"].toString());
    data2 = data2.substring(2);
    const Utf8Encoder encoder = Utf8Encoder();
    List<int> value = hex.decode(data2);
    Uint8List encodedData = Uint8List.fromList(value);
    var tx;
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: "0x392F7bAccBfE1324df91298ae9Ffc153111CED7c",
        data: encodedData,
        value: BigInt.parse(price),
        nonce: nonce,
        gas: 1500000); //TODO: test if stating gas is necessary

    print("Bought!");
    print(tx);
  }

  void cancelToken(double tokenAmount, String buildingId, String tokenAddress) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/cancelSale'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'tokenAmount': tokenAmount,
        'tokenAddress': tokenAddress,

      }),
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String data2 = decodedRsp["abi"];
    int nonce = int.parse(decodedRsp["nonce"].toString());
    data2 = data2.substring(2);
    const Utf8Encoder encoder = Utf8Encoder();
    List<int> value = hex.decode(data2);
    Uint8List encodedData = Uint8List.fromList(value);
    var tx;

    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: "0x392F7bAccBfE1324df91298ae9Ffc153111CED7c",
        data: encodedData,
        nonce: nonce,
        gas: 1500000); //TODO: test if stating gas is necessary

    print("Canceled!");
    print(tx);
  }

  beforeVoting() async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'),
      //REMEMBER TO CHANGE IP ADDRESS
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

    Map<String, dynamic> decodedRsp = json.decode(rsp.body);
    String price = (double.parse(decodedRsp["price"]) / (pow(10, 18)))
        .toString();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return VotingPage(title: 'Voting',
          authToken: widget.authToken,
          localIp: widget.localIp,
          accountAddress: widget.accountAddress,
          provider: widget.provider, tokenAddress: "0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f");
    }));
  }

  beforeRent() async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'),
      //REMEMBER TO CHANGE IP ADDRESS
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

    Map<String, dynamic> decodedRsp = json.decode(rsp.body);
    String price = (double.parse(decodedRsp["price"]) / (pow(10, 18)))
        .toString();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return RentPage(title: 'Rent',
          authToken: widget.authToken,
          localIp: widget.localIp,
          accountAddress: widget.accountAddress,
          provider: widget.provider);
    }));
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      //_selectedIndex = index;
    });
    if(index == 1){
      await beforeRent();
    }
    else if (index == 2) {
      await beforeVoting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.toll),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Rent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Governance',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Center(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Token Price: ' + widget.currentPrice + ' Ξ',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Balance:',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                '55 tokens',
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                '1.85 ether',
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: pricePerTokenController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Price per Token',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: amountToSellController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount of Tokens',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => sellToken(double.parse(pricePerTokenController.text), double.parse(amountToSellController.text), "628b802a01929414d3cfaab8", "0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f"),
                  //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Sell Tokens'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: amountToBuyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount of Tokens',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: Text(
                'X tokens will cost Y eth',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => buyToken(double.parse(amountToBuyController.text), "628b802a01929414d3cfaab8", "0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f"),
                child: const Text('Buy Tokens'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: amountToCancelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount of Tokens',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: Text(
                'You have X tokens on sale',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrange,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => cancelToken(double.parse(amountToCancelController.text), "628b802a01929414d3cfaab8", "0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f"),
                child: const Text('Cancel Sale'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlueAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () async { beforeRent(); },

                child: const Text('Rent'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purpleAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () async { beforeVoting(); },

                child: const Text('Voting'),
              ),
            ),


          ],

        ),
      ),
    );
  }
}