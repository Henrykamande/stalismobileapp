import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import './http.dart';

class SyncService with ChangeNotifier {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  ConnectivityResult get internetConnectivity => _connectionStatus;

  final StreamController<List<Map<String, dynamic>>> _dataStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get dataStream => _dataStreamController.stream;

  Future<void> updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
    notifyListeners();
  }


  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }

  // start of products sync
  // Future<int> syncRecords() async {
  //   try {
  //     var resultCode = 0;
  //     if (_connectionStatus != ConnectivityResult.none) {
  //       final prefsData = await getSharedData();
  //       var headers = jsonEncode(prefsData['headers']);
  //       var productsResponse = await offlineHttpPost('sync-records', headers);
  //
  //       var decodedData = jsonDecode(productsResponse.body);
  //       resultCode = decodedData['ResultCode'];
  //
  //       notifyListeners();
  //     }
  //
  //     return resultCode;
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

//  end of products sync
}
