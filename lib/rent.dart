import 'dart:math';

import 'package:dstate/proposals.dart';
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

import 'individual_proposal.dart';

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
  bool isDialogShown = false;

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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress,
        data: encodedData,
        value: rentPrice,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
    print("Rent withdrawn!");
    print(tx);
  }

  void withdrawPreviousRent(String buildingId, String tokenAddress, int previousRentNumber) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/building/withdrawPreviousRent'), //REMEMBER TO CHANGE IP ADDRESS
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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
    print("Rent withdrawn!");
    print(tx);
  }

  void suggestDepositReturn(String buildingId, String tokenAddress, int suggestedAmount) async {
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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
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
    isDialogShown = true;
    _showDialog(context);
    tx = await widget.provider.sendTransaction(from: widget.accountAddress,
        to: widget.rentAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
    print("Accepted or Denied!");
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
    //String title;
    //String description;
    //int proposalType;
    //int id;
    //int uint0;
    //int uint1;
    //int uint2;
    //String address0;

    for(dynamic prop in list) {
      final String title = prop["title"];
      final String description = prop["description"];
      final int proposalType = int.parse(prop["proposalType"]);
      final int id = int.parse(prop["id"]);
      final int uint0 = int.parse(prop["uint0"]);
      final int uint1 = int.parse(prop["uint1"]);
      final int uint2 = int.parse(prop["uint2"]);
      final String address0 = prop["address0"];

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
      int id, int uint0, int uint1, int uint2, String address0) async {


    String votesNumber;
    bool accepted;

    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/token/checkForProposals'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'proposalId': id,
        'tokenAddress': widget.tokenAddress,

      }),//TODO: lazy loading
    );
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    var prop = decodedRsp["proposals"];

    String sendProposalType = "";
    String sendUint0 = "";
    String sendUint1 = "";
    String sendUint2 = "";
    String sendAddress0 = "";


    switch (proposalType) {
      case 0:
        {
          sendProposalType = "Generic Proposal";

        }
        break;
      case 1:
        {
          sendProposalType = "Change Rent Price";
          sendUint0 = "New Rent Price: " + uint0.toString();
        }
        break;
      case 2:
        {
          sendProposalType = "Change Deposit Price";
          sendUint0 = "New Deposit Price: " + uint0.toString();
        }
        break;
      case 3:
        {
          sendProposalType = "Change Caretaker Share";
          sendUint0 = "New Caretaker Share: " + uint0.toString();

        }
        break;
      case 4:
        {
          sendProposalType = "Replace Caretaker";
          sendAddress0 = "New Caretaker: " + address0;

        }
        break;
      case 5:
        {
          sendProposalType = "Remove Tenant";

        }
        break;
      case 6:
        {
          sendProposalType = "Accept New Tenant";
          sendUint0 = "Contract: " + uint0.toString() + " Months";
          sendUint1 = "Rent Price: " + uint0.toString();
          sendUint2 = "Deposit Price: " + uint0.toString();
          sendAddress0 = "New Tenant: " + address0;

        }
        break;
      case 7:
        {
          sendProposalType = "Renew Contract";
          sendUint0 = "Additional Months: " + uint0.toString();

        }
        break;
    }

    votesNumber = prop[0]["votesN"];
    accepted = prop[0]["votingResult"];
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
          proposalType: sendProposalType,
          id: id,
          uint0: sendUint0,
          uint1: sendUint1,
          uint2: sendUint2,
          address0: sendAddress0,
          votesNumber: votesNumber,
          accepted: accepted
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
                'Token Price:  ??',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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