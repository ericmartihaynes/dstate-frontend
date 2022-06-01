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


class TokenPage extends StatefulWidget {
  const TokenPage ({Key? key, required this.title, required this.provider, required this.authToken, required this.localIp, required this.buildingId, required this.accountAddress}) : super(key: key);


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
  final String buildingId;
  final String accountAddress;



  @override
  State<TokenPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TokenPage> {
  int _counter = 0;
  final nameController = TextEditingController();
  final symbolController = TextEditingController();
  final amountController = TextEditingController();
  final rentPriceController = TextEditingController(text: "0");
  final depositPriceController = TextEditingController(text: "0");
  final remainingMonthsController = TextEditingController(text: "0");
  final caretakerShareController = TextEditingController(text: "0");
  final caretakerController = TextEditingController(text: "0x0000000000000000000000000000000000000000");
  final tenantController = TextEditingController(text: "0x0000000000000000000000000000000000000000");
  bool isDialogShown = false;
  bool forRent = false;

  //Send data to backend
  Future<Response> sendData(String name, String symbol, double tokenAmount, double rentPrice, double depositPrice, int remainingMonths, int caretakerShare, String caretaker, String tenant) {
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
        'symbol': symbol,
        'building_id': widget.buildingId,
        'rentPrice': (rentPrice * pow(10,18)).toInt(), //times 10**18
        'depositPrice': (depositPrice * pow(10,18)).toInt(), //times 10**18
        'remainingMonths': remainingMonths,
        'caretakerShare': caretakerShare,
        'caretaker': caretaker,
        'tenant': tenant
      }),
    );
    //CHANGE TO JSON CALL
  }





  Future<Response> createToken(String name, String symbol, double tokenAmount, String buildingId, double rentPrice, double depositPrice, int remainingMonths, int caretakerShare, String caretaker, String tenant) async {
    Response rsp = await sendData(name, symbol, tokenAmount, rentPrice, depositPrice, remainingMonths, caretakerShare, caretaker, tenant);
    Map<String, dynamic> decodedRsp =json.decode(rsp.body);
    String data2 = decodedRsp["abi"];
    data2 = data2.substring(2);
    const Utf8Encoder encoder = Utf8Encoder();
    //String data = "60806040523480156200001157600080fd5b5060405162001b8038038062001b808339818101604052810190620000379190620004c8565b816040516020016200004a9190620005ff565b6040516020818303038152906040528181600390805190602001906200007292919062000240565b5080600490805190602001906200008b92919062000240565b505050620000b533670de0b6b3a764000085620000a9919062000654565b620000be60201b60201c565b50505062000827565b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160362000130576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401620001279062000716565b60405180910390fd5b62000144600083836200023660201b60201c565b806002600082825462000158919062000738565b92505081905550806000808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254620001af919062000738565b925050819055508173ffffffffffffffffffffffffffffffffffffffff16600073ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef83604051620002169190620007a6565b60405180910390a362000232600083836200023b60201b60201c565b5050565b505050565b505050565b8280546200024e90620007f2565b90600052602060002090601f016020900481019282620002725760008555620002be565b82601f106200028d57805160ff1916838001178555620002be565b82800160010185558215620002be579182015b82811115620002bd578251825591602001919060010190620002a0565b5b509050620002cd9190620002d1565b5090565b5b80821115620002ec576000816000905550600101620002d2565b5090565b6000604051905090565b600080fd5b600080fd5b6000819050919050565b620003198162000304565b81146200032557600080fd5b50565b60008151905062000339816200030e565b92915050565b600080fd5b600080fd5b6000601f19601f8301169050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b620003948262000349565b810181811067ffffffffffffffff82111715620003b657620003b56200035a565b5b80604052505050565b6000620003cb620002f0565b9050620003d9828262000389565b919050565b600067ffffffffffffffff821115620003fc57620003fb6200035a565b5b620004078262000349565b9050602081019050919050565b60005b838110156200043457808201518184015260208101905062000417565b8381111562000444576000848401525b50505050565b6000620004616200045b84620003de565b620003bf565b90508281526020810184848401111562000480576200047f62000344565b5b6200048d84828562000414565b509392505050565b600082601f830112620004ad57620004ac6200033f565b5b8151620004bf8482602086016200044a565b91505092915050565b600080600060608486031215620004e457620004e3620002fa565b5b6000620004f48682870162000328565b935050602084015167ffffffffffffffff811115620005185762000517620002ff565b5b620005268682870162000495565b925050604084015167ffffffffffffffff8111156200054a5762000549620002ff565b5b620005588682870162000495565b9150509250925092565b600081905092915050565b7f6473746174652d00000000000000000000000000000000000000000000000000600082015250565b6000620005a560078362000562565b9150620005b2826200056d565b600782019050919050565b600081519050919050565b6000620005d582620005bd565b620005e1818562000562565b9350620005f381856020860162000414565b80840191505092915050565b60006200060c8262000596565b91506200061a8284620005c8565b915081905092915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b6000620006618262000304565b91506200066e8362000304565b9250817fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0483118215151615620006aa57620006a962000625565b5b828202905092915050565b600082825260208201905092915050565b7f45524332303a206d696e7420746f20746865207a65726f206164647265737300600082015250565b6000620006fe601f83620006b5565b91506200070b82620006c6565b602082019050919050565b600060208201905081810360008301526200073181620006ef565b9050919050565b6000620007458262000304565b9150620007528362000304565b9250827fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff038211156200078a576200078962000625565b5b828201905092915050565b620007a08162000304565b82525050565b6000602082019050620007bd600083018462000795565b92915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b600060028204905060018216806200080b57607f821691505b602082108103620008215762000820620007c3565b5b50919050565b61134980620008376000396000f3fe608060405234801561001057600080fd5b50600436106100a95760003560e01c80633950935111610071578063395093511461016857806370a082311461019857806395d89b41146101c8578063a457c2d7146101e6578063a9059cbb14610216578063dd62ed3e14610246576100a9565b806306fdde03146100ae578063095ea7b3146100cc57806318160ddd146100fc57806323b872dd1461011a578063313ce5671461014a575b600080fd5b6100b6610276565b6040516100c39190610c04565b60405180910390f35b6100e660048036038101906100e19190610cbf565b610308565b6040516100f39190610d1a565b60405180910390f35b61010461032b565b6040516101119190610d44565b60405180910390f35b610134600480360381019061012f9190610d5f565b610335565b6040516101419190610d1a565b60405180910390f35b610152610364565b60405161015f9190610dce565b60405180910390f35b610182600480360381019061017d9190610cbf565b61036d565b60405161018f9190610d1a565b60405180910390f35b6101b260048036038101906101ad9190610de9565b610417565b6040516101bf9190610d44565b60405180910390f35b6101d061045f565b6040516101dd9190610c04565b60405180910390f35b61020060048036038101906101fb9190610cbf565b6104f1565b60405161020d9190610d1a565b60405180910390f35b610230600480360381019061022b9190610cbf565b6105db565b60405161023d9190610d1a565b60405180910390f35b610260600480360381019061025b9190610e16565b6105fe565b60405161026d9190610d44565b60405180910390f35b60606003805461028590610e85565b80601f01602080910402602001604051908101604052809291908181526020018280546102b190610e85565b80156102fe5780601f106102d3576101008083540402835291602001916102fe565b820191906000526020600020905b8154815290600101906020018083116102e157829003601f168201915b5050505050905090565b600080610313610685565b905061032081858561068d565b600191505092915050565b6000600254905090565b600080610340610685565b905061034d858285610856565b6103588585856108e2565b60019150509392505050565b60006012905090565b600080610378610685565b905061040c818585600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008973ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020546104079190610ee5565b61068d565b600191505092915050565b60008060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020549050919050565b60606004805461046e90610e85565b80601f016020809104026020016040519081016040528092919081815260200182805461049a90610e85565b80156104e75780601f106104bc576101008083540402835291602001916104e7565b820191906000526020600020905b8154815290600101906020018083116104ca57829003601f168201915b5050505050905090565b6000806104fc610685565b90506000600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020549050838110156105c2576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016105b990610fad565b60405180910390fd5b6105cf828686840361068d565b60019250505092915050565b6000806105e6610685565b90506105f38185856108e2565b600191505092915050565b6000600160008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905092915050565b600033905090565b600073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16036106fc576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016106f39061103f565b60405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160361076b576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610762906110d1565b60405180910390fd5b80600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925836040516108499190610d44565b60405180910390a3505050565b600061086284846105fe565b90507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81146108dc57818110156108ce576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016108c59061113d565b60405180910390fd5b6108db848484840361068d565b5b50505050565b600073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603610951576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610948906111cf565b60405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16036109c0576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016109b790611261565b60405180910390fd5b6109cb838383610b61565b60008060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905081811015610a51576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610a48906112f3565b60405180910390fd5b8181036000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002081905550816000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254610ae49190610ee5565b925050819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef84604051610b489190610d44565b60405180910390a3610b5b848484610b66565b50505050565b505050565b505050565b600081519050919050565b600082825260208201905092915050565b60005b83811015610ba5578082015181840152602081019050610b8a565b83811115610bb4576000848401525b50505050565b6000601f19601f8301169050919050565b6000610bd682610b6b565b610be08185610b76565b9350610bf0818560208601610b87565b610bf981610bba565b840191505092915050565b60006020820190508181036000830152610c1e8184610bcb565b905092915050565b600080fd5b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000610c5682610c2b565b9050919050565b610c6681610c4b565b8114610c7157600080fd5b50565b600081359050610c8381610c5d565b92915050565b6000819050919050565b610c9c81610c89565b8114610ca757600080fd5b50565b600081359050610cb981610c93565b92915050565b60008060408385031215610cd657610cd5610c26565b5b6000610ce485828601610c74565b9250506020610cf585828601610caa565b9150509250929050565b60008115159050919050565b610d1481610cff565b82525050565b6000602082019050610d2f6000830184610d0b565b92915050565b610d3e81610c89565b82525050565b6000602082019050610d596000830184610d35565b92915050565b600080600060608486031215610d7857610d77610c26565b5b6000610d8686828701610c74565b9350506020610d9786828701610c74565b9250506040610da886828701610caa565b9150509250925092565b600060ff82169050919050565b610dc881610db2565b82525050565b6000602082019050610de36000830184610dbf565b92915050565b600060208284031215610dff57610dfe610c26565b5b6000610e0d84828501610c74565b91505092915050565b60008060408385031215610e2d57610e2c610c26565b5b6000610e3b85828601610c74565b9250506020610e4c85828601610c74565b9150509250929050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b60006002820490506001821680610e9d57607f821691505b602082108103610eb057610eaf610e56565b5b50919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b6000610ef082610c89565b9150610efb83610c89565b9250827fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff03821115610f3057610f2f610eb6565b5b828201905092915050565b7f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f7760008201527f207a65726f000000000000000000000000000000000000000000000000000000602082015250565b6000610f97602583610b76565b9150610fa282610f3b565b604082019050919050565b60006020820190508181036000830152610fc681610f8a565b9050919050565b7f45524332303a20617070726f76652066726f6d20746865207a65726f2061646460008201527f7265737300000000000000000000000000000000000000000000000000000000602082015250565b6000611029602483610b76565b915061103482610fcd565b604082019050919050565b600060208201905081810360008301526110588161101c565b9050919050565b7f45524332303a20617070726f766520746f20746865207a65726f20616464726560008201527f7373000000000000000000000000000000000000000000000000000000000000602082015250565b60006110bb602283610b76565b91506110c68261105f565b604082019050919050565b600060208201905081810360008301526110ea816110ae565b9050919050565b7f45524332303a20696e73756666696369656e7420616c6c6f77616e6365000000600082015250565b6000611127601d83610b76565b9150611132826110f1565b602082019050919050565b600060208201905081810360008301526111568161111a565b9050919050565b7f45524332303a207472616e736665722066726f6d20746865207a65726f20616460008201527f6472657373000000000000000000000000000000000000000000000000000000602082015250565b60006111b9602583610b76565b91506111c48261115d565b604082019050919050565b600060208201905081810360008301526111e8816111ac565b9050919050565b7f45524332303a207472616e7366657220746f20746865207a65726f206164647260008201527f6573730000000000000000000000000000000000000000000000000000000000602082015250565b600061124b602383610b76565b9150611256826111ef565b604082019050919050565b6000602082019050818103600083015261127a8161123e565b9050919050565b7f45524332303a207472616e7366657220616d6f756e742065786365656473206260008201527f616c616e63650000000000000000000000000000000000000000000000000000602082015250565b60006112dd602683610b76565b91506112e882611281565b604082019050919050565b6000602082019050818103600083015261130c816112d0565b905091905056fea26469706673582212205c1058e74e836a5b190f69583bf34ca2c98b5e80d81b028e96a112a52d859cc364736f6c634300080d00330000000000000000000000000000000000000000000000000000000000000929000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000004736466670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044453543100000000000000000000000000000000000000000000000000000000";
    List<int> value = hex.decode(data2);
    //Uint8List encodedData = encoder.convert(data);
    Uint8List encodedData = Uint8List.fromList(value);
    isDialogShown = true;
    _showDialog(context);
    final tx = await widget.provider.sendTransaction(from: widget.accountAddress, data: encodedData, gas: 15000000);
    if(isDialogShown){Navigator.pop(context);}
    Navigator.pop(context);
    print("Deployed!");
    print(tx);

    return post(
      Uri.parse('http://' + widget.localIp + ':3001/building/createToken'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + widget.authToken,
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'initial_amount': tokenAmount.toInt().toString(),
        'building_id': buildingId,
        'symbol': symbol,
        'transactionHash' : tx,
      }),
    );
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

  changeRentalStatus(){
    if(!forRent){
      rentPriceController.text = "0";
      depositPriceController.text = "0";
      remainingMonthsController.text = "0";
      caretakerShareController.text = "0";
      caretakerController.text = "0x0000000000000000000000000000000000000000";
      tenantController.text = "0x0000000000000000000000000000000000000000";
    }
    else {
      rentPriceController.text = "";
      depositPriceController.text = "";
      remainingMonthsController.text = "";
      caretakerShareController.text = "";
      caretakerController.text = "";
      tenantController.text = "";
    }
  }
//TODO: check if it works without touching switch
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
                controller: nameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Name of Token',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: symbolController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Symbol',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: amountController,
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
                'Rental',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Transform.scale(
                scale: 1.5,
                child: Switch(
                    value: forRent,
                    onChanged: (forRent) => {
                        setState(() => this.forRent = forRent), changeRentalStatus()})), //
            Visibility(
              visible: forRent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: rentPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Rent Price',
                  ),
                ),
              ),
            ),
            Visibility(
              visible: forRent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: depositPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Deposit Price',
                  ),
                ),
              ),
            ),
            Visibility(
              visible: forRent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: remainingMonthsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Duration of contract (Months)',
                  ),
                ),
              ),
            ),
            Visibility(
              visible: forRent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: caretakerShareController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Caretaker Share of Rent (0-100)',
                  ),
                ),
              ),
            ),
            Visibility(
              visible: forRent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: caretakerController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Caretaker Public Address',
                  ),
                ),
              ),
            ),
            Visibility(
              visible: forRent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: tenantController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Tenant Public Address',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  primary: Colors.amber,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () => createToken(nameController.text, symbolController.text, double.parse(amountController.text), widget.buildingId, double.parse(rentPriceController.text), double.parse(depositPriceController.text), int.parse(remainingMonthsController.text), int.parse(caretakerShareController.text), caretakerController.text, tenantController.text),
                child: const Text('Create Token'),
              ),
            ),
          ],

        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
