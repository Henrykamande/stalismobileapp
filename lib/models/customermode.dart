// To parse this JSON data, do
//
//     final customerData = customerDataFromJson(jsonString);

import 'dart:convert';

CustomerData customerDataFromJson(String str) =>
    CustomerData.fromJson(json.decode(str));

String customerDataToJson(CustomerData data) => json.encode(data.toJson());

class CustomerData {
  CustomerData({
    required this.resultState,
    required this.resultCode,
    required this.resultDesc,
    required this.responseData,
  });

  bool resultState;
  int resultCode;
  String resultDesc;
  List<CustomersResponseDatum> responseData;

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
        resultState: json["ResultState"],
        resultCode: json["ResultCode"],
        resultDesc: json["ResultDesc"],
        responseData: List<CustomersResponseDatum>.from(json["ResponseData"]
            .map((x) => CustomersResponseDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResultState": resultState,
        "ResultCode": resultCode,
        "ResultDesc": resultDesc,
        "ResponseData": List<dynamic>.from(responseData.map((x) => x.toJson())),
      };
}

class CustomersResponseDatum {
  CustomersResponseDatum({
    required this.id,
    required this.cardCode,
    required this.name,
    this.phoneNumber,
    this.email,
    this.balance,
    required this.openingBalance,
    this.creditLimit,
    this.advancePayment,
    required this.userId,
    required this.status,
    required this.cardType,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    required this.storeId,
    this.address,
    this.paymentTerm,
  });

  int id;
  int cardCode;
  String name;
  String? phoneNumber;
  String? email;
  dynamic? balance;
  int openingBalance;
  dynamic creditLimit;
  dynamic advancePayment;
  int userId;
  Status status;
  CardType cardType;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  int storeId;
  String? address;
  dynamic paymentTerm;

  factory CustomersResponseDatum.fromJson(
          Map<CustomersResponseDatum, dynamic> json) =>
      CustomersResponseDatum(
        id: json["id"],
        cardCode: json["CardCode"],
        name: json["Name"],
        phoneNumber: json["PhoneNumber"] == null ? null : json["PhoneNumber"],
        email: json["Email"] == null ? null : json["Email"],
        balance: json["Balance"],
        openingBalance:
            json["OpeningBalance"] == null ? null : json["OpeningBalance"],
        creditLimit: json["CreditLimit"],
        advancePayment: json["AdvancePayment"],
        userId: json["user_id"],
        status: statusValues.map[json["Status"]]!,
        cardType: cardTypeValues.map[json["CardType"]]!,
        deletedAt: json["deleted_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        storeId: json["store_id"] == null ? null : json["store_id"],
        address: json["Address"] == null ? null : json["Address"],
        paymentTerm: json["paymentTerm"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "CardCode": cardCode,
        "Name": name,
        "PhoneNumber": phoneNumber == null ? null : phoneNumber,
        "Email": email == null ? null : email,
        "Balance": balance,
        "OpeningBalance": openingBalance == null ? null : openingBalance,
        "CreditLimit": creditLimit,
        "AdvancePayment": advancePayment,
        "user_id": userId,
        "Status": statusValues.reverse![status]!,
        "CardType": cardTypeValues.reverse![cardType],
        "deleted_at": deletedAt,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "store_id": storeId == null ? null : storeId,
        "Address": address == null ? null : address,
        "paymentTerm": paymentTerm,
      };
}

enum CardType { C }

final cardTypeValues = EnumValues({"C": CardType.C});

enum Status { Y }

final statusValues = EnumValues({"Y": Status.Y});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
