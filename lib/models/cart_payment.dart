import 'package:flutter/foundation.dart';

class CartPayment with ChangeNotifier {
  final dynamic id;
  final String name;
  dynamic amount;

  CartPayment({ required this.id, required this.name, required this.amount });

  factory CartPayment.fromJson(Map<String, dynamic> json) => CartPayment(
      id: json["id"],
      name: json['name'],
      amount: json['amount'],);


  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "amount": amount,
  };
}