import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

class PrintOrders {
  final String orderType;
  final String orderNumber;
  final String customerName;
  final String deliveryTime;
  final String instruction;
  final List<String> items;

  PrintOrders(
      {required this.orderNumber,
      required this.orderType,
      required this.instruction,
      required this.items,
      required this.customerName,
      required this.deliveryTime});
}

PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
List<PrinterBluetooth> _devices = [];
String _devicesMsg = "No printer";
BluetoothManager bluetoothManager = BluetoothManager.instance;
