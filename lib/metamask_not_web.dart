import 'package:flutter/cupertino.dart';

class MetaMaskProvider extends ChangeNotifier {
  static const operatingChain = 4;

  String currentAddress = '';

  int currentChain = -1;

  bool get isEnabled => false;

  bool get isInOperatingChain => currentChain == operatingChain;

  bool get isConnected => isEnabled && currentAddress.isNotEmpty;

  Future<void> connect() async {

  }

  clear() {
    currentAddress = '';
    currentChain = -1;
    notifyListeners();
  }

  init() {

  }
}