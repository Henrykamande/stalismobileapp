import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

///Test printing
class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

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

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printCustom("Printer Test Page ", 0, 1);
        bluetooth.printNewLine();
        //bluetooth.printImage(file.path); //path of your image/logo
        bluetooth.printNewLine();
        //bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
        bluetooth.printNewLine();
        //bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printLeftRight("LEFT", "RIGHT", 0,
            format:
            "%-15s %15s %n"); //15 is number off character from left or right
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printNewLine();
        bluetooth.print3Column("Col1", "Col2", "Col3", 0);
        bluetooth.print3Column("Col1", "Col2", "Col3", 0,
            format:
            "%-10s %10s %10s %n"); //10 is number off character from left center and right
        bluetooth.printNewLine();
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 0);
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 0,
            format: "%-8s %7s %7s %7s %n");
        bluetooth.printNewLine();
        bluetooth.printCustom("čĆžŽšŠ-H-ščđ", 0, 0, charset: "windows-1250");
        bluetooth.printLeftRight("Številka:", "18000001", 0,
            charset: "windows-1250");
        bluetooth.printCustom("Body left", 0, 0);
        bluetooth.printCustom("Body right", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }
}
