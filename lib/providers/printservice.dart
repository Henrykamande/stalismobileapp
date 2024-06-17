// import 'dart:convert';
// import 'dart:core';
// // import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:testproject/constants/constants.dart';
// import 'package:testproject/providers/shared_preferences_services.dart';
//
// import '../databasesql/sql_database_connection.dart';
//
// class PrinterService with ChangeNotifier {
//
//   List availableBluetoothDevices = [];
//   bool connected = false;
//
//   Future<void> getBluetooth() async {
//   // print(' trying to connect ');
//   //   try {
//   //     final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
//   //     print("Print bluetooths 1 $bluetooths");
//   //
//   //       availableBluetoothDevices = bluetooths ?? []; // Use empty list if null
//   //
//   //     connected = false;
//   //   } catch (e) {
//   //     print("Error fetching Bluetooth devices: $e");
//   //   }
//   }
//
//   void disconnectPrinters() {
//     availableBluetoothDevices = [];
//     connected = false;
//   }
//
//   Future<void> printSaleReceipt(saleCard) async {
//     //
//     // var mac = await DatabaseHelper.instance.getDefaultPrinter();
//     //
//     // print(' connected status $connected');
//     // connected = true;
//     //
//     // print(' connected status 2 $connected');
//     //
//     // // printTicket();
//     //
//     // try {
//     //   final String? result = await BluetoothThermalPrinter.connect(mac);
//     //   print('Connect result: $result');
//     //   if (result == "true") {
//     //
//     //       connected = true;
//     //
//     //     printTicket(saleCard);
//     //   }
//     // } catch (e) {
//     //   print("Error connecting to printer: $e");
//     // }
//   }
//
//   Future<void> printTicket(saleCard) async {
//     // try {
//     //   String? isConnected = await BluetoothThermalPrinter.connectionStatus;
//     //   if (isConnected == "true") {
//     //     List<int> bytes = await getTicket();
//     //     final result = await BluetoothThermalPrinter.writeBytes(bytes);
//     //     print("Print result: $result");
//     //   } else {
//     //     print("Printer is not connected.");
//     //   }
//     // } catch (e) {
//     //   print("Error printing ticket: $e");
//     // }
//   }
//
// }
//
// Future<List<int>> getTicket() async {
//   List<int> bytes = [];
//   CapabilityProfile profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);
//
//   bytes += generator.text("Demo Shop",
//       styles: PosStyles(
//         align: PosAlign.center,
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//       linesAfter: 1);
//
//   bytes += generator.text(
//       "18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078",
//       styles: PosStyles(align: PosAlign.center));
//   bytes += generator.text('Tel: +919591708470',
//       styles: PosStyles(align: PosAlign.center));
//
//   bytes += generator.hr();
//   bytes += generator.row([
//     PosColumn(
//         text: 'No',
//         width: 1,
//         styles: PosStyles(align: PosAlign.left, bold: true)),
//     PosColumn(
//         text: 'Item',
//         width: 5,
//         styles: PosStyles(align: PosAlign.left, bold: true)),
//     PosColumn(
//         text: 'Price',
//         width: 2,
//         styles: PosStyles(align: PosAlign.center, bold: true)),
//     PosColumn(
//         text: 'Qty',
//         width: 2,
//         styles: PosStyles(align: PosAlign.center, bold: true)),
//     PosColumn(
//         text: 'Total',
//         width: 2,
//         styles: PosStyles(align: PosAlign.right, bold: true)),
//   ]);
//
//   bytes += generator.row([
//     PosColumn(text: "1", width: 1),
//     PosColumn(
//         text: "Tumeric soap ayurvedic small",
//         width: 5,
//         styles: PosStyles(
//           align: PosAlign.left,
//         )),
//     PosColumn(
//         text: "10",
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         )),
//     PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
//     PosColumn(text: "10", width: 2, styles: PosStyles(align: PosAlign.right)),
//   ]);
//
//   bytes += generator.row([
//     PosColumn(text: "2", width: 1),
//     PosColumn(
//         text: "Sada Dosa",
//         width: 5,
//         styles: PosStyles(
//           align: PosAlign.left,
//         )),
//     PosColumn(
//         text: "30",
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         )),
//     PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
//     PosColumn(text: "30", width: 2, styles: PosStyles(align: PosAlign.right)),
//   ]);
//
//   bytes += generator.row([
//     PosColumn(text: "3", width: 1),
//     PosColumn(
//         text: "Masala Dosa",
//         width: 5,
//         styles: PosStyles(
//           align: PosAlign.left,
//         )),
//     PosColumn(
//         text: "50",
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         )),
//     PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
//     PosColumn(text: "50", width: 2, styles: PosStyles(align: PosAlign.right)),
//   ]);
//
//   bytes += generator.row([
//     PosColumn(text: "4", width: 1),
//     PosColumn(
//         text: "Rova Dosa",
//         width: 5,
//         styles: PosStyles(
//           align: PosAlign.left,
//         )),
//     PosColumn(
//         text: "70",
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         )),
//     PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
//     PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
//   ]);
//
//   bytes += generator.hr();
//
//   bytes += generator.row([
//     PosColumn(
//         text: 'TOTAL',
//         width: 6,
//         styles: PosStyles(
//           align: PosAlign.left,
//           height: PosTextSize.size4,
//           width: PosTextSize.size4,
//         )),
//     PosColumn(
//         text: "160",
//         width: 6,
//         styles: PosStyles(
//           align: PosAlign.right,
//           height: PosTextSize.size4,
//           width: PosTextSize.size4,
//         )),
//   ]);
//
//   bytes += generator.hr(ch: '=', linesAfter: 1);
//
//   // ticket.feed(2);
//   bytes += generator.text('Thank you!',
//       styles: PosStyles(align: PosAlign.center, bold: true));
//
//   bytes += generator.text("26-11-2020 15:22:45",
//       styles: PosStyles(align: PosAlign.center), linesAfter: 1);
//
//   bytes += generator.text(
//       'Note: Goods once sold will not be taken back or exchanged.',
//       styles: PosStyles(align: PosAlign.center, bold: false));
//   bytes += generator.cut();
//   return bytes;
// }
//
// // Future<List<int>> getTicket(saleCard) async {
// //   List<int> bytes = [];
// //   CapabilityProfile profile = await CapabilityProfile.load();
// //   final ticket = Generator(PaperSize.mm80, profile);
// //
// //   print(' sale card data $saleCard');
// //
// //
// //   bytes += ticket.text('MILEVA BEAUTY',
// //       styles: PosStyles(align: PosAlign.center));
// //   bytes += ticket.text('DUBOIS ROAD, AFRICANA STALLS',
// //       styles: PosStyles(align: PosAlign.center));
// //   bytes += ticket.text('SHOP 10A',
// //       styles: PosStyles(align: PosAlign.center));
// //   bytes += ticket.text('Tel: 0722561469 / 0757660406',
// //       styles: PosStyles(align: PosAlign.center),  linesAfter: 1);
// //   // bytes += ticket.text('Web: www.example.com',
// //   //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);
// //
// //   bytes += ticket.text('--------------------------------',
// //       styles: PosStyles(align: PosAlign.center));
// //
// //   bytes += ticket.row([
// //     PosColumn(text: 'Item        Qty       Total', width: 12),
// //     // PosColumn(text: 'Quantity', width: 4),
// //     // PosColumn(
// //     //     text: 'Total', width: 4, styles: PosStyles(align: PosAlign.right)),
// //   ]);
// //
// //   for (var cartItem in saleCard.rows) {
// //     bytes += ticket.row([
// //       PosColumn(text: '${cartItem.name}', width: 12),
// //       // PosColumn(text: '${cartItem.name}', width: 7),
// //       // PosColumn(
// //       //     text: '${cartItem.price}', width: 2, styles: PosStyles(align: PosAlign.right)),
// //       // PosColumn(
// //       //     text: '${cartItem.lineTotal}', width: 2, styles: PosStyles(align: PosAlign.right)),
// //     ]);
// //   }
// //
// //
// //   bytes += ticket.text('--------------------------------',
// //       styles: PosStyles(align: PosAlign.center));
// //
// //   bytes += ticket.row([
// //     PosColumn(
// //         text: 'TOTAL',
// //         width: 6,
// //         styles: PosStyles(
// //           height: PosTextSize.size2,
// //           width: PosTextSize.size2,
// //         )),
// //     PosColumn(
// //         text: '${saleCard.docTotal}',
// //         width: 6,
// //         styles: PosStyles(
// //           align: PosAlign.right,
// //           height: PosTextSize.size2,
// //           width: PosTextSize.size2,
// //         )),
// //   ]);
// //
// //   bytes += ticket.text('--------------------------------',
// //       styles: PosStyles(align: PosAlign.center), linesAfter: 1);
// //
// //
// //
// //   bytes += ticket.feed(2);
// //   bytes += ticket.text('Thank you!',
// //       styles: PosStyles(align: PosAlign.center, bold: true));
// //
// //   final now = DateTime.now();
// //   final formatter = DateFormat('MM/dd/yyyy H:m');
// //   final String timestamp = formatter.format(now);
// //   bytes += ticket.text(timestamp,
// //       styles: PosStyles(align: PosAlign.center), linesAfter: 2);
// //
// //   // Print QR Code from image
// //   // try {
// //   //   const String qrData = 'example.com';
// //   //   const double qrSize = 200;
// //   //   final uiImg = await QrPainter(
// //   //     data: qrData,
// //   //     version: QrVersions.auto,
// //   //     gapless: false,
// //   //   ).toImageData(qrSize);
// //   //   final dir = await getTemporaryDirectory();
// //   //   final pathName = '${dir.path}/qr_tmp.png';
// //   //   final qrFile = File(pathName);
// //   //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
// //   //   final img = decodeImage(imgFile.readAsBytesSync());
// //
// //   //   bytes += ticket.image(img);
// //   // } catch (e) {
// //   //   print(e);
// //   // }
// //
// //   // Print QR Code using native function
// //   // bytes += ticket.qrcode('example.com');
// //
// //   ticket.feed(2);
// //   ticket.cut();
// //   return bytes;
// // }
