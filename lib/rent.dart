import 'dart:math';

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

final previousRentController = TextEditingController();
final depositProposalController = TextEditingController();
final depositAcceptRejectController = TextEditingController();
int _selectedIndex = 1;

class RentPage extends StatefulWidget {
  const RentPage(
      {Key? key, required this.title, required this.authToken, required this.localIp, required this.accountAddress, required this.provider, required this.buildingId, required this.tokenAddress, required this.rentAddress})
      : super(key: key);
  final String title;
  final String authToken;
  final String localIp;
  final String accountAddress;
  final EthereumWalletConnectProvider provider;
  final String buildingId;
  final String tokenAddress;
  final String rentAddress;
  @override
  State<RentPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RentPage> {

  void requestRent(String buildingId, String tokenAddress) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/requestRent'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,

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
        to: widget.rentAddress, //TODO: Change this!!!!!!!!!!!!!!!!!!!!
        data: encodedData,
        nonce: nonce,
        gas: 1500000);

    print("Requested!");
    print(tx);
  }

  void payRent(String buildingId, String tokenAddress) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/rent'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,

      }),
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);

    String data2 = decodedRsp["abi"];
    int nonce = int.parse(decodedRsp["nonce"].toString());
    BigInt rentPrice = BigInt.from(int.parse(decodedRsp["rentPrice"].toString())); //make sure getting deposit as well
    data2 = data2.substring(2);
    const Utf8Encoder encoder = Utf8Encoder();
    List<int> value = hex.decode(data2);
    Uint8List encodedData = Uint8List.fromList(value);
    var tx;
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress, //TODO: Change this!!!!!!!!!!!!!!!!!!!!
        data: encodedData,
        value: rentPrice,
        nonce: nonce,
        gas: 1500000);

    print("Paid!");
    print(tx);
  }

  void withdrawRent(String buildingId, String tokenAddress) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/withdrawRent'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,

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
        to: widget.rentAddress, //TODO: Change this!!!!!!!!!!!!!!!!!!!!
        data: encodedData,
        nonce: nonce,
        gas: 1500000);

    print("Rent withdrawn!");
    print(tx);
  }

  void withdrawPreviousRent(String buildingId, String tokenAddress, int previousRentNumber) async { //TODO: Needs route
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/requestRent'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'missed': previousRentNumber,

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
        to: widget.rentAddress, //TODO: Change this!!!!!!!!!!!!!!!!!!!!
        data: encodedData,
        nonce: nonce,
        gas: 1500000);

    print("Rent withdrawn!");
    print(tx);
  }

  void suggestDepositReturn(String buildingId, String tokenAddress, int suggestedAmount) async { //TODO: route needs to ask for suggested amount
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/submitDepositProposal'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'suggestedAmount': suggestedAmount,

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
        to: widget.rentAddress, //TODO: Change this!!!!!!!!!!!!!!!!!!!!
        data: encodedData,
        nonce: nonce,
        gas: 1500000);

    print("Suggested!");
    print(tx);
  }

  void acceptDepositReturn(String buildingId, String tokenAddress, bool accepted) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/respondToProposal'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'acceptance': accepted,

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
        to: widget.rentAddress, //TODO: Change this!!!!!!!!!!!!!!!!!!!!
        data: encodedData,
        nonce: nonce,
        gas: 1500000);

    print("Accepted or Denied!");
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
        'building_id': widget.buildingId,
        'tokenAmount': 1,
        'tokenAddress': widget.tokenAddress,

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
          provider: widget.provider,
          buildingId: widget.buildingId,
          tokenAddress: widget.tokenAddress,
          rentAddress: widget.rentAddress);
    }));
  }

  beforeBuySell(String tokenAddress) async {

    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/getPriceForTokens'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': widget.buildingId,
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
      Uri.parse('http://' + widget.localIp + ':3001/users/balanceInEth'), //REMEMBER TO CHANGE IP ADDRESS
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },

    );

    Map<String, dynamic> decodedRsp3 =json.decode(rsp3.body);
    String eth = (decodedRsp3["balance"]).toString();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {

      return BuySellPage(context: context,title: 'Buy / Sell', authToken: widget.authToken, localIp: widget.localIp,
          accountAddress: widget.accountAddress, provider: widget.provider, currentPrice: price, currentTokenBalance: tokens, currentEthBalance: eth, buildingId: '62936fec385e672267bc77ee', tokenAddress: tokenAddress, rentAddress: '0x7aA7b5e70D361c3e1Fc9E24a841f1440276d0d74');

    }));
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      //_selectedIndex = index;
    });
    if(index == 0){
      await beforeBuySell(widget.tokenAddress);
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
                'Token Price:  Ξ',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purpleAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => requestRent(widget.buildingId, widget.tokenAddress),
                  //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Request Rent'),
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
                onPressed: () => payRent(widget.buildingId, widget.tokenAddress),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Pay Rent'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreenAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => withdrawRent(widget.buildingId, widget.tokenAddress),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Withdraw Rent'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: previousRentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Previous Rent Number',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => withdrawPreviousRent(widget.buildingId, widget.tokenAddress, int.parse(previousRentController.text)),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Withdraw Previous Rent'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: depositProposalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Deposit Amount to Return',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => suggestDepositReturn(widget.buildingId, widget.tokenAddress, int.parse(depositProposalController.text)),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Suggest Deposit Return'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: depositAcceptRejectController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'true || false',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => acceptDepositReturn(widget.buildingId, widget.tokenAddress, depositAcceptRejectController.text == "true"),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Accept / Reject Deposit Return'),
              ),
            ),

          ],

        ),
      ),
    );
  }
}