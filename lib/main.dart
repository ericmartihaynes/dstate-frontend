import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
//web3
import 'package:dstate/metamask_not_web.dart' if (dart.library.js) 'package:dstate/metamask_web.dart';
import 'package:dstate/transaction_sender.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:dart_web3/dart_web3.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Create Your Token'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  //Send data to backend
  Future<Response> sendData(String name, double tokenAmount) {
    print(name + " " + tokenAmount.toString());
    return post(
      Uri.parse('http://localhost:3001/building'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Name': name,
        'Amount': tokenAmount.toString(),
      }),
    );
    //CHANGE TO JSON CALL
  }

  //Connect to Wallet
  _walletConnect() async {
    //Wallet Connect Mobile
    if(Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android) {
      final connector = WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        clientMeta: const PeerMeta(
          name: 'WalletConnect',
          description: 'WalletConnect Developer App',
          url: 'https://walletconnect.org',
          icons: [
            'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ),
      );
      // Subscribe to events
      connector.on('connect', (session) => print(session));
      connector.on('session_update', (payload) => print(payload));
      connector.on('disconnect', (session) => print(session));

      // Create a new session


      final session = await connector.createSession(
          chainId: 4, //Rinkeby is 4, Ethereum is 1
          onDisplayUri: (uri) async =>
          {print(uri), await launchUrl(
            Uri.parse(uri),
            mode: LaunchMode.externalApplication,
          )});


      setState(() {
        final account = session.accounts[0];
      });

      String rpcUrl = "https://rinkeby.infura.io/v3/2af9187666bc4f2485d90c76f9727138";
      var credentials; //This should be what is sent to the backend eventually
      //if (account != null) {
      final client = Web3Client(rpcUrl, Client());
      EthereumWalletConnectProvider provider =
      EthereumWalletConnectProvider(connector);
      credentials = WalletConnectEthereumCredentials(provider: provider);
      //yourContract = YourContract(address: contractAddr, client: client);
      //}
    }
    //Wallet Connect Web
    else {
      MetaMaskProvider metamask = MetaMaskProvider();
      await metamask.connect();
      print(metamask.currentAddress);
      print(metamask.currentChain);
    }
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                controller: amountController,
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
                  primary: Colors.white24,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                ),
                onPressed: () async => _walletConnect(),
                child: const Text('Connect Wallet'),
              ),
            ),
          ],

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> sendData(nameController.text, double.parse(amountController.text)),
        tooltip: 'Increment',
        child: const Icon(Icons.check),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
