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
final uint0Controller = TextEditingController();
final uint1Controller = TextEditingController();
final uint2Controller = TextEditingController();
final address0Controller = TextEditingController();
final proposalIdController = TextEditingController();
int _selectedIndex = 2;

class individualProposalPage extends StatefulWidget {
  const individualProposalPage(
      {Key? key, required this.title, required this.authToken, required this.localIp, required this.accountAddress, required this.provider,
        required this.buildingId, required this.tokenAddress, required this.rentAddress, required this.title2, required this.description,
        required this.proposalType, required this.id, required this.uint0, required this.uint1, required this.uint2, required this.address0,
        required this.votesNumber, required this.accepted})
      : super(key: key);
  final String title;
  final String authToken;
  final String localIp;
  final String accountAddress;
  final EthereumWalletConnectProvider provider;
  final String tokenAddress;
  final String buildingId;
  final String rentAddress;
  final String title2;
  final String description;
  final String proposalType;
  final int id;
  final String uint0;
  final String uint1;
  final String uint2;
  final String address0;
  final String votesNumber;
  final bool accepted;

  @override
  State<individualProposalPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<individualProposalPage> {
  bool isDialogShown = false;

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
    Navigator.pop(context);
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
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shadowColor: Colors.purple,
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
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
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.title2,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.proposalType,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Proposal id: ' + widget.id.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.uint0,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.uint1,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.uint2,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.address0,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Votes: ' + widget.votesNumber,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Accepted: ' + widget.accepted.toString(),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.cyanAccent,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => vote(widget.buildingId, widget.tokenAddress, widget.id),
                //{/*628b802a01929414d3cfaab8*/ /*0xe922e9152c588e9fceddd239f6aaf19b2eec0d6f*/},
                child: const Text('Vote'),
              ),
            ),


          ],

        ),
      ),
    );
  }
}