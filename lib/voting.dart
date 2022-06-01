import 'dart:math';

import 'package:dstate/rent.dart';
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

final titleController = TextEditingController();
final descriptionController = TextEditingController();
final proposalTypeController = TextEditingController();
final uint0Controller = TextEditingController(text:"0");
final uint1Controller = TextEditingController(text:"0");
final uint2Controller = TextEditingController(text:"0");
final address0Controller = TextEditingController(text:"0x0000000000000000000000000000000000000000");
final proposalIdController = TextEditingController();
int _selectedIndex = 2;

class VotingPage extends StatefulWidget {
  const VotingPage(
      {Key? key, required this.title, required this.authToken, required this.localIp, required this.accountAddress, required this.provider,  required this.buildingId, required this.tokenAddress, required this.rentAddress})
      : super(key: key);
  final String title;
  final String authToken;
  final String localIp;
  final String accountAddress;
  final EthereumWalletConnectProvider provider;
  final String tokenAddress;
  final String buildingId;
  final String rentAddress;
  @override
  State<VotingPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VotingPage> {
  bool isDialogShown = false;
  List<String> proposalTypes = ["Generic Proposal", "Change Price Rent Price", "Change Deposit Price",
    "Change Caretaker Share", "Replace Caretaker", "Remove Tenant", "Accept New Tenant", "Renew Current Contract"];
  String selectedProposalType = "Generic Proposal";
  bool showUint0 = false;
  bool showUint1 = false;
  bool showUint2 = false;
  bool showAddress0 = false;
  String labelUint0 = "";
  String labelUint1 = "";
  String labelUint2 = "";
  String labelAddress0 = "";


  void createProposal(String buildingId, String tokenAddress, String title, String description, int proposalType, int uint0, int uint1, int uint2, String address0) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/token/createProposal'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'tokenAddress':tokenAddress,
        'title':title,
        'description':description,
        'proposalType':proposalType,
        'uint0':uint0,
        'uint1':uint1,
        'uint2':uint2,
        'address0':address0,
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
        to: tokenAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
    print("Proposed!");
    print(tx);
    Navigator.pop(context);
  }

  void vote(String buildingId, String tokenAddress,int proposalId) async {
    Response rsp = await post(
      Uri.parse('http://' + widget.localIp + ':3001/token/submitVote'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, dynamic>{
        'building_id': buildingId,
        'tokenAddress':tokenAddress,
        'proposalId':proposalId,
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
        to: tokenAddress,
        data: encodedData,
        nonce: nonce,
        gas: 1500000);
    if(isDialogShown){Navigator.pop(context);}
    print("Voted!");
    print(tx);
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
    else if (index == 1) {
      await beforeRent();
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

  changeProposalType() {
    int type = 0;
    switch (selectedProposalType) {
      case "Generic Proposal":
        {
          type = 0;
          showUint0 = false;
          uint0Controller.text = "0";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = false;
          address0Controller.text = "0x0000000000000000000000000000000000000000";
        }
        break;
      case "Change Price Rent Price":
        {
          type = 1;
          showUint0 = true;
          uint0Controller.text = "";
          labelUint0 = "New Rent Price";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = false;
          address0Controller.text = "0x0000000000000000000000000000000000000000";
        }
        break;
      case "Change Deposit Price":
        {
          type = 2;
          showUint0 = true;
          uint0Controller.text = "";
          labelUint0 = "New Deposit Price";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = false;
          address0Controller.text = "0x0000000000000000000000000000000000000000";
        }
        break;
      case "Change Caretaker Share":
        {
          type = 3;
          showUint0 = true;
          uint0Controller.text = "";
          labelUint0 = "New Caretaker Share";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = false;
          address0Controller.text = "0x0000000000000000000000000000000000000000";
        }
        break;
      case "Replace Caretaker":
        {
          type = 4;
          showUint0 = false;
          uint0Controller.text = "0";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = true;
          address0Controller.text = "";
          labelAddress0 = "New Caretaker Public Address";
        }
        break;
      case "Remove Tenant":
        {
          type = 5;
          showUint0 = false;
          uint0Controller.text = "0";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = false;
          address0Controller.text = "0x0000000000000000000000000000000000000000";
        }
        break;
      case "Accept New Tenant":
        {
          type = 6;
          showUint0 = true;
          uint0Controller.text = "";
          labelUint0 = "Duration of contract (Months)";
          showUint1 = true;
          uint1Controller.text = "";
          labelUint1 = "New Rent Price";
          showUint2 = true;
          uint2Controller.text = "";
          labelUint2 = "New Deposit Price";
          showAddress0 = true;
          address0Controller.text = "";
          labelAddress0 = "New Tenant Public Address";
        }
        break;
      case "Renew Current Contract":
        {
          type = 7;
          showUint0 = true;
          uint0Controller.text = "";
          labelUint0 = "Extension of contract (Months)";
          showUint1 = false;
          uint1Controller.text = "0";
          showUint2 = false;
          uint2Controller.text = "0";
          showAddress0 = false;
          address0Controller.text = "0x0000000000000000000000000000000000000000";
        }
        break;

    }
    proposalTypeController.text = type.toString();

  }

//TODO: Make adaptive
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Title',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                  value: selectedProposalType,
                  items: proposalTypes
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (item) => {setState(() => selectedProposalType = item.toString()), changeProposalType()}),
            ),//
            Visibility(
              visible: showUint0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: uint0Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: labelUint0,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: showUint1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: uint1Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: labelUint1,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: showUint2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: uint2Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: labelUint2,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: showAddress0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: address0Controller,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: labelAddress0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.cyan,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => createProposal(widget.buildingId, widget.tokenAddress, titleController.text, descriptionController.text, int.parse(proposalTypeController.text), int.parse(uint0Controller.text), int.parse(uint1Controller.text), int.parse(uint2Controller.text), address0Controller.text),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Create Proposal'),
              ),
            ),

          ],

        ),
      ),
    );
  }
}