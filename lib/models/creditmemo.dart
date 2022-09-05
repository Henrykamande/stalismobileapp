// To parse this JSON data, do
//
//     final creditMemo = creditMemoFromJson(jsonString);

import 'dart:convert';

CreditMemo creditMemoFromJson(String str) =>
    CreditMemo.fromJson(json.decode(str));

String creditMemoToJson(CreditMemo data) => json.encode(data.toJson());

class CreditMemo {
  CreditMemo({
    required this.customerName,
    required this.customerPhone,
    required this.storeId,
    required this.returnedProducts,
    required this.replacedProducts,
    required this.topupPayments,
  });

  String customerName;
  String customerPhone;
  int storeId;
  List<ReturnedProduct> returnedProducts;
  List<ReplacedProduct> replacedProducts;
  List<TopupPayment> topupPayments;

  factory CreditMemo.fromJson(Map<String, dynamic> json) => CreditMemo(
        customerName: json["customerName"],
        customerPhone: json["customerPhone"],
        storeId: json["store_id"],
        returnedProducts: List<ReturnedProduct>.from(
            json["returnedProducts"].map((x) => ReturnedProduct.fromJson(x))),
        replacedProducts: List<ReplacedProduct>.from(
            json["replacedProducts"].map((x) => ReplacedProduct.fromJson(x))),
        topupPayments: List<TopupPayment>.from(
            json["topupPayments"].map((x) => TopupPayment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "customerName": customerName,
        "customerPhone": customerPhone,
        "store_id": storeId,
        "returnedProducts":
            List<dynamic>.from(returnedProducts.map((x) => x.toJson())),
        "replacedProducts":
            List<dynamic>.from(replacedProducts.map((x) => x.toJson())),
        "topupPayments":
            List<dynamic>.from(topupPayments.map((x) => x.toJson())),
      };
}

class ReplacedProduct {
  ReplacedProduct({
    required this.productName,
    required this.productId,
    required this.quantity,
    required this.sellingPrice,
    this.taxId,
    required this.lineTotal,
    this.ref1,
  });

  String productName;
  String? ref1;
  int productId;
  int quantity;
  int sellingPrice;
  int? taxId;
  int lineTotal;

  factory ReplacedProduct.fromJson(Map<String, dynamic> json) =>
      ReplacedProduct(
        productName: json["productName"],
        productId: json["productId"],
        quantity: json["Quantity"],
        sellingPrice: json["sellingPrice"],
        taxId: json["TaxId"],
        lineTotal: json["LineTotal"],
        ref1: json["Ref1"],
      );

  Map<String, dynamic> toJson() => {
        "productName": productName,
        "productId": productId,
        "Quantity": quantity,
        "sellingPrice": sellingPrice,
        "TaxId": taxId,
        "LineTotal": lineTotal,
        "ref1": ref1,
      };
}

class ReturnedProduct {
  ReturnedProduct({
    required this.productName,
    required this.productId,
    required this.quantity,
    required this.sellingPrice,
    required this.lineTotal,
    this.ref1,
  });

  String productName;
  String? ref1;
  int productId;
  int quantity;
  int sellingPrice;
  int lineTotal;

  factory ReturnedProduct.fromJson(Map<String, dynamic> json) =>
      ReturnedProduct(
        productName: json["productName"],
        productId: json["ProductId"],
        quantity: json["Quantity"],
        sellingPrice: json["sellingPrice"],
        lineTotal: json["LineTotal"],
        ref1: json['Ref1'],
      );

  Map<String, dynamic> toJson() => {
        "productName": productName,
        "ProductId": productId,
        "Quantity": quantity,
        "sellingPrice": sellingPrice,
        "LineTotal": lineTotal,
        "Ref1": ref1,
      };
}

class TopupPayment {
  TopupPayment({
    this.paymentMode,
    this.accountId,
    this.amount,
  });

  String? paymentMode;
  int? accountId;
  int? amount;

  factory TopupPayment.fromJson(Map<String, dynamic> json) => TopupPayment(
        paymentMode: json["paymentMode"],
        accountId: json["accountId"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "paymentMode": paymentMode,
        "accountId": accountId,
        "amount": amount,
      };
}
