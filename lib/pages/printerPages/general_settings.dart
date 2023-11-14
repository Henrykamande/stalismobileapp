// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:testproject/providers/api_service.dart';
// import 'package:testproject/providers/productslist_provider.dart';
// import 'package:testproject/pages/printerPages/testprint.dart';
// import 'package:flutter_switch/flutter_switch.dart';
//
// class PrintPage extends StatefulWidget {
//   State<PrintPage> createState() => _PrintPageState();
// }
//
// class _PrintPageState extends State<PrintPage> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     var defaultPrinter = Provider.of<GetProducts>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Select Printer"),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(30.0),
//           child: Container(
//             child: ListView(
//               children: <Widget>[
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       'Device:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 30,
//                     ),
//                     Expanded(
//                       child: DropdownButton(
//                         items: _getDeviceItems(),
//                         onChanged: (BluetoothDevice? value) => setState(() {
//                           _selecteddevice = value;
//                           print('On change selected printer $_selecteddevice');
//                           defaultPrinter
//                               .defaultPrinterAddress(_selecteddevice!.address);
//                         }),
//                         value: _selecteddevice,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(primary: Colors.brown),
//                       onPressed: () {
//                         initPlatformState();
//                       },
//                       child: Text(
//                         'Refresh',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10.0,
//                     ),
//                     ElevatedButton(
//                       /* shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       color: _connected ? Colors.green : Colors.red, */
//                       onPressed: _connected ? _disconnect : _connect,
//                       child: Text(
//                         _connected ? 'connected' : 'connect',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(primary: Colors.brown),
//                     onPressed: () {
//                       /* bluetooth.printCustom('Shop Name', 1, 2);
//                       bluetooth.printCustom('', 1, 2);
//
//                       bluetooth.print3Column('Qty', 'Price', 'Total', 0);
//
//                       bluetooth.printNewLine();
//                       bluetooth.printNewLine();
//                       bluetooth.printNewLine();
//
//                       bluetooth.paperCut(); */
//                       _testPrint.sample();
//                     },
//                     child: Text('Test Print'),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10.0,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
//     List<DropdownMenuItem<BluetoothDevice>> items = [];
//     if (_devices.isEmpty) {
//       items.add(DropdownMenuItem(
//         child: Text('NONE'),
//       ));
//     } else {
//       var listPrinters = Provider.of<ProductListProvider>(context);
//       listPrinters.addPrinter(_devices);
//
//       /* var existingItem = _devices.firstWhere(
//           (itemToCheck) => itemToCheck.address == '57:4C:54:02:80:D7');
//       print(
//           '============================================================ ${existingItem.name}'); */
//       _devices.forEach((device) {
//         items.add(DropdownMenuItem(
//           child: Column(
//             children: [Text(device.name ?? ""), Text(device.address ?? "")],
//           ),
//           value: device,
//         ));
//       });
//     }
//     return items;
//   }
//
//   void _connect() {
//     if (_selecteddevice != null) {
//       print('Selected device connect method $_selecteddevice');
//       bluetooth.isConnected.then((isConnected) {
//         print(isConnected);
//         if (isConnected == false) {
//           bluetooth.connect(_selecteddevice!).catchError((error) {
//             print(error);
//             setState(() => _connected = false);
//           });
//           setState(() => _connected = true);
//         }
//       });
//     } else {
//       show('No device selected.');
//     }
//   }
//
//   void _disconnect() {
//     bluetooth.disconnect();
//     setState(() => _connected = false);
//   }
//
//   Future show(
//     String message, {
//     Duration duration: const Duration(seconds: 3),
//   }) async {
//     await new Future.delayed(new Duration(milliseconds: 100));
//     ScaffoldMessenger.of(context).showSnackBar(
//       new SnackBar(
//         content: new Text(
//           message,
//           style: new TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         duration: duration,
//       ),
//     );
//   }
// }
