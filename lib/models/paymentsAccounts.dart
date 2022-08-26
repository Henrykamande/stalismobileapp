// To parse this JSON data, do
//
//     final pamentAccounts = pamentAccountsFromJson(jsonString);

import 'dart:convert';

PamentAccounts pamentAccountsFromJson(String str) =>
    PamentAccounts.fromJson(json.decode(str));

String pamentAccountsToJson(PamentAccounts data) => json.encode(data.toJson());

class PamentAccounts {
  PamentAccounts({
    required this.resultState,
    required this.resultCode,
    required this.resultDesc,
    required this.responseData,
  });

  bool resultState;
  int resultCode;
  String resultDesc;
  PaymentAccountsResponseData responseData;

  factory PamentAccounts.fromJson(Map<String, dynamic> json) => PamentAccounts(
        resultState: json["ResultState"],
        resultCode: json["ResultCode"],
        resultDesc: json["ResultDesc"],
        responseData:
            PaymentAccountsResponseData.fromJson(json["ResponseData"]),
      );

  Map<String, dynamic> toJson() => {
        "ResultState": resultState,
        "ResultCode": resultCode,
        "ResultDesc": resultDesc,
        "ResponseData": responseData.toJson(),
      };
}

class PaymentAccountsResponseData {
  PaymentAccountsResponseData({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.userId,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.code,
    required this.bankingAcc,
  });

  int id;
  String name;
  String type;
  int balance;
  int userId;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  int category;
  int code;
  String bankingAcc;

  factory PaymentAccountsResponseData.fromJson(Map<String, dynamic> json) =>
      PaymentAccountsResponseData(
        id: json["id"],
        name: json["Name"],
        type: json["Type"],
        balance: json["Balance"],
        userId: json["user_id"],
        deletedAt: json["deleted_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        category: json["Category"],
        code: json["code"],
        bankingAcc: json["BankingAcc"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Name": name,
        "Type": type,
        "Balance": balance,
        "user_id": userId,
        "deleted_at": deletedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "Category": category,
        "code": code,
        "BankingAcc": bankingAcc,
      };
}
