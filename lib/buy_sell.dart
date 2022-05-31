import 'dart:math';

import 'package:dstate/proposals.dart';
import 'package:dstate/rent.dart';
import 'package:dstate/voting.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';

import 'package:dstate/buy_sell.dart';
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

import 'individual_proposal.dart';

final pricePerTokenController = TextEditingController();
final amountToSellController = TextEditingController();
final amountToBuyController = TextEditingController();
final amountToCancelController = TextEditingController();
int _selectedIndex = 0;



class BuySellPage extends StatefulWidget {
  const BuySellPage(
      {Key? key, required this.context, required this.title, required this.authToken, required this.localIp, required this.accountAddress, required this.provider, required this.currentPrice, required this.currentTokenBalance,  required this.currentEthBalance, required this.buildingId, required this.tokenAddress, required this.rentAddress})
      : super(key: key);
  final BuildContext context;
  final String title;
  final String authToken;
  final String localIp;
  final String accountAddress;
  final EthereumWalletConnectProvider provider;
  final String currentPrice;
  final String currentTokenBalance;
  final String currentEthBalance;
  final String buildingId;
  final String tokenAddress;
  final String rentAddress;

  @override
  State<BuySellPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BuySellPage> {
  bool isDialogShown = false;
  String buySellAddress = "0xc5C00BAb417678FcE914E312dA401569b007b50F";

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
    bool needToApprove = decodedRsp["approve"];
    data2 = data2.substring(2);
    const Utf8Encoder encoder = Utf8Encoder();
    List<int> value = hex.decode(data2);
    Uint8List encodedData = Uint8List.fromList(value);
    var tx;
    if(!needToApprove) {
      isDialogShown = true;
      _showDialog(context);
      tx = await widget.provider.sendTransaction(from: widget.accountAddress,
          to: buySellAddress,
          data: encodedData,
          nonce: nonce,
          gas: 1500000);
      if(isDialogShown){Navigator.pop(context);}
      print("Sold!");
      print(tx);
    }
    else{
      isDialogShown = true;
      _showDialog(context);
      tx = await widget.provider.sendTransaction(from: widget.accountAddress,
          to: widget.tokenAddress,
          data: encodedData,
          gas: 1500000);
      if(isDialogShown){Navigator.pop(context);}
      print("Approved!");
      print(tx);
    }

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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: buySellAddress,
        data: encodedData,
        value: BigInt.parse(price),
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}

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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: buySellAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
    print("Canceled!");
    print(tx);
  }

  beforeVoting() async {
    List<Widget> proposals = [];
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/token/checkForProposals'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'proposalNumber': 10,
        'previousId': 0,
        'tokenAddress': widget.tokenAddress,

      }),//TODO: lazy loading
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    //dev.log(decodedRsp.toString());

    Widget proposal;
    var list = decodedRsp["proposals"];
    String title;
    String description;
    int proposalType;
    int id;
    int uint0;
    int uint1;
    int uint2;
    String address0;
    for(dynamic prop in list) {
      title = prop["title"];
      description = prop["description"];
      proposalType = int.parse(prop["proposalType"]);
      id = int.parse(prop["id"]);
      uint0 = int.parse(prop["uint0"]);
      uint1 = int.parse(prop["uint1"]);
      uint2 = int.parse(prop["uint2"]);
      address0 = prop["address0"];

      proposal = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shadowColor: Colors.purple,
          elevation: 8,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),

          ),
          child: InkWell(
            onTap: () {beforeIndividualProposal(title, description, proposalType,
                id, uint0, uint1, uint2, address0);},
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.purple],
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      proposals.add(proposal);

    }


    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProposalsPage(title: 'Proposals',
          authToken: widget.authToken,
          localIp: widget.localIp,
          accountAddress: widget.accountAddress,
          provider: widget.provider,
          buildingId: widget.buildingId,
          tokenAddress: widget.tokenAddress,
          rentAddress: widget.rentAddress,
          proposals: proposals);
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
        'building_id': widget.buildingId,
        'tokenAmount': 1,
        'tokenAddress': widget.tokenAddress,

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
          provider: widget.provider,
      buildingId: widget.buildingId,
      tokenAddress: widget.tokenAddress,
      rentAddress: widget.rentAddress);
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

  _showDialog(BuildContext context) {
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

  beforeIndividualProposal(String title, String description, int proposalType,
      int id, int uint0, int uint1, int uint2, String address0) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return individualProposalPage(
        title: title,
        authToken: widget.authToken,
        localIp: widget.localIp,
        accountAddress: widget.accountAddress,
        provider: widget.provider,
        buildingId: widget.buildingId,
        tokenAddress: widget.tokenAddress,
        rentAddress: widget.rentAddress,
        title2: title,
        description: description,
        proposalType: proposalType,
        id: id,
        uint0: uint0,
        uint1: uint1,
        uint2: uint2,
        address0: address0,
      );
    }));
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                widget.currentTokenBalance + ' tokens',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                widget.currentEthBalance + ' Ξ',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.redAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => sellToken(double.parse(pricePerTokenController.text), double.parse(amountToSellController.text), widget.buildingId, widget.tokenAddress),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.greenAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => buyToken(double.parse(amountToBuyController.text), widget.buildingId, widget.tokenAddress),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.deepOrange,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => cancelToken(double.parse(amountToCancelController.text), widget.buildingId, widget.tokenAddress),
                child: const Text('Cancel Sale'),
              ),
            ),
            
          ],

        ),
      ),
    );
  }
}