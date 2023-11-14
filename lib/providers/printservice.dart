import 'dart:convert';
import 'dart:core';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/constants/constants.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

class PrinterService with ChangeNotifier {
  // BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  PrefService _prefs = PrefService();
  late bool _connected;
  String printerErrorMessage = "";
  var cache;
  String _storename = '';
  var _macaaddress = '';

  get macaddress => _macaaddress;

  String get storename => _storename;

  bool get isconnected => _connected;
  // List<BluetoothDevice> devices = [];

  Future<void> initPlatformState() async {
    // try {
    //   devices = await bluetooth.getBondedDevices();
    // } on PlatformException {}

    // bluetooth.onStateChanged().listen((state) {
    //   switch (state) {
    //     case BlueThermalPrinter.CONNECTED:
    //       _connected = true;
    //
    //       print("bluetooth device state: connected");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.DISCONNECTED:
    //       _connected = false;
    //       print("bluetooth device state: disconnected");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.DISCONNECT_REQUESTED:
    //       _connected = false;
    //       print("bluetooth device state: disconnect requested");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.STATE_TURNING_OFF:
    //       _connected = false;
    //       print("bluetooth device state: bluetooth turning off");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.STATE_OFF:
    //       _connected = false;
    //       print("bluetooth device state: bluetooth off");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.STATE_ON:
    //       _connected = false;
    //       print("bluetooth device state: bluetooth on");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.STATE_TURNING_ON:
    //       _connected = false;
    //       print("bluetooth device state: bluetooth turning on");
    //       notifyListeners();
    //
    //       break;
    //     case BlueThermalPrinter.ERROR:
    //       _connected = false;
    //       print("bluetooth device state: error");
    //       notifyListeners();
    //
    //       break;
    //     default:
    //       print(state);
    //       break;
    //   }
    // });

    /* if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    } */
    notifyListeners();
  }

  sethenders() async {
    cache = await _prefs.readCache(
        'Token', 'StoreId', 'loggedinUserName', 'storename');

    String token = cache['Token'];
    String storeId = cache['StoreId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };

    _storename = cache['storename'];
    notifyListeners();
    return headers;
  }

  getPrinterAddress() async {
    var headers = await sethenders();
    var url =
        Uri.https(baseUrl, '/api/v1/store-mac-address/${headers['storeid']}');
    var response = await http.get(
      url,
      headers: headers,
    );
    var data = await jsonDecode(response.body);

    print('State Printer ${data['ResponseData']}');
    _macaaddress = data['ResponseData'];
    notifyListeners();
    return data['ResponseData'];
  }
  //
  // void connect() async {
  //   var _activedevices = await bluetooth.getBondedDevices();
  //   var existingprinter = _activedevices
  //       .firstWhere((itemToCheck) => itemToCheck.address == macaddress);
  //
  //   print('Selected device connect method $existingprinter');
  //   bluetooth.isConnected.then((isConnected) {
  //     print(isConnected);
  //     if (isConnected == false) {
  //       bluetooth.connect(existingprinter).catchError((error) {
  //         print(error);
  //
  //         _connected = false;
  //         printerErrorMessage = "Set Default Printer ";
  //         notifyListeners();
  //       });
  //       _connected = true;
  //       notifyListeners();
  //     }
  //   });
  //   notifyListeners();
  // }
  //
  // disconnect() {
  //   _connected = false;
  //   bluetooth.disconnect();
  //   notifyListeners();
  //   return _connected;
  // }
}
