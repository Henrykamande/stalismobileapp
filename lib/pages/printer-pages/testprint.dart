import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'package:http/http.dart' as http;

///Test printing
class TestPrint {


  sample() async {
    //image max 300px X 300px

    ///image from File path
    /*  String filename = 'icon.jpg';
    ByteData bytesData = await rootBundle.load("icon/icon.jpg");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    ///image from Asset
    ByteData bytesAsset = await rootBundle.load("assets/icon/icon.jpg");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);
 */
    ///image from Network
    /*  var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes); */


  }
}
