import 'package:flutter/material.dart';

class OutSourcedProducts {
  String productName;
  int quantity;
  double buyingPrice;
  double sellingPrice;
  double totalAmount;
  OutSourcedProducts(
      {required this.buyingPrice,
      required this.productName,
      required this.quantity,
      required this.sellingPrice,
      required this.totalAmount});
}
