import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/widgets/custom_appbar.dart';
import 'package:testproject/widgets/drawer_screen.dart';

import '../../databasesql/sql_database_connection.dart';

class PrinterSetupScreen extends StatefulWidget {
  static const routeName = '/printer-setup';
  const PrinterSetupScreen({Key? key}) : super(key: key);

  @override
  State<PrinterSetupScreen> createState() => _PrinterSetupScreenState();
}

class _PrinterSetupScreenState extends State<PrinterSetupScreen> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  PrinterBluetooth? _selectedPrinter;

  // void _startScanDevices() {
  //   printerManager.startScan(Duration(seconds: 2));
  //
  //  // _getBluetoothDevices();
  // }

//   void _example() {
//     PrinterBluetoothManager printerManager = PrinterBluetoothManager();
//
//     printerManager.scanResults.listen((printers) async {
//       // store found printers
//       print("printers examples$printers");
//     });
//     printerManager.startScan(Duration(seconds: 4));
//
// // ...
//
//
//   }

  void _scanPrinters() {
    _startScanDevices();

    printerManager.scanResults.listen((devices) async {
      print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    // setState(() {
    //   _devices = [];
    // });
    printerManager.startScan(Duration(seconds: 2));
  }

  void _getBluetoothDevices() {
    print("getBluetoothDevices");
    try {
      printerManager.startScan(Duration(seconds: 2));
    } catch (e) {
      print('eror printer $e');
    }
    printerManager.scanResults.listen((devices) async {
      print(' setup printers $devices');

      if (devices.isNotEmpty) {
        _devices = devices;
        _selectedPrinter = _devices[0];
      }

      if (devices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You dont have any bluetooth printers connected'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  // if(devices.isNotEmpty) {
  //   _devices = devices;
  //   _selectedPrinter = _devices[0];
  // }
  //
  // if(devices.isEmpty) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('You dont have any bluetooth printers connected'),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();

    printerManager.startScan(Duration(seconds: 4));

    printerManager.scanResults.listen((devices) async {
      print(' setup printers 1 $devices');

      setState(() {
        print(' setup printers $devices');
      });
    });

    Future.delayed(Duration(seconds: 2), () {
      printerManager.stopScan();
    });
  }

  dynamic setDefaultPrinter(printerData) async {
    var details = {
      'printer_name': printerData.name,
      'printer_address': printerData.address
    };
    await DatabaseHelper.instance.setDefaultPrinter(details).then((value) {
      print(' setting printer response');
    });
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];

    // Print image
    // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final Image? image = decodeImage(imageBytes);
    // bytes += ticket.image(image);

    bytes += ticket.text('GROCERYLY',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += ticket.text('889  Watson Lane',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('New Braunfels, TX',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('Tel: 830-221-1234',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('Web: www.example.com',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += ticket.row([
      PosColumn(text: '2', width: 1),
      PosColumn(text: 'ONION RINGS', width: 7),
      PosColumn(
          text: '0.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '1.98', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'PIZZA', width: 7),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'SPRING ROLLS', width: 7),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '3', width: 1),
      PosColumn(text: 'CRUNCHY STICKS', width: 7),
      PosColumn(
          text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    bytes += ticket.row([
      PosColumn(
          text: 'Cash',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$15.00',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Change',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$4.03',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    bytes += ticket.feed(2);
    bytes += ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    ticket.feed(2);
    ticket.cut();
    return bytes;
  }

  void _testPrint(PrinterBluetooth? printer) async {
    printerManager.selectPrinter(printer!);

    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    final PosPrintResult res =
        await printerManager.printTicket((await demoReceipt(paper, profile)));

    showToast(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    var defaultPrinter = Provider.of<GetProducts>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerScreen(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            child: ListView(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: DropdownButton<PrinterBluetooth>(
                        items: removeDuplicates(_getDeviceItems()),
                        onChanged: (value) {
                          _selectedPrinter = value!;
                          setDefaultPrinter(_selectedPrinter);
                        },
                        value: _selectedPrinter,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      //style: ElevatedButton.styleFrom(primary: Colors.brown),
                      onPressed: () {
                        _startScanDevices();
                      },
                      child: Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                  child: ElevatedButton(
                    //style: ElevatedButton.styleFrom(primary: Colors.brown),
                    onPressed: () {
                      _testPrint(_selectedPrinter);
                    },
                    child: Text('Test Print'),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<PrinterBluetooth>> _getDeviceItems() {
    List<DropdownMenuItem<PrinterBluetooth>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      var listPrinters = Provider.of<ProductListProvider>(context);
      listPrinters.addPrinter(_devices);

      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Column(
            children: [Text(device.name ?? ""), Text(device.address ?? "")],
          ),
          value: device,
        ));
      });
    }
    return items;
  }

// remove duplicate values
  List<T> removeDuplicates<T>(List<T> list) {
    Set<T> uniqueSet = Set<T>.from(list);
    List<T> uniqueList = uniqueSet.toList();
    return uniqueList;
  }
}
