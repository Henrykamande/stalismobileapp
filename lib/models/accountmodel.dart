// To parse this JSON data, do
//
//     final account = accountFromJson(jsonString);

import 'dart:convert';

Account accountFromJson(String str) => Account.fromJson(json.decode(str));

String accountToJson(Account data) => json.encode(data.toJson());

class Account {
  Account({
    required this.resultState,
    required this.resultCode,
    required this.resultDesc,
    required this.responseData,
  });

  bool resultState;
  int resultCode;
  String resultDesc;
  List<ResponseDatumAccounts> responseData;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        resultState: json["ResultState"],
        resultCode: json["ResultCode"],
        resultDesc: json["ResultDesc"],
        responseData: List<ResponseDatumAccounts>.from(
            json["ResponseData"].map((x) => ResponseDatumAccounts.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResultState": resultState,
        "ResultCode": resultCode,
        "ResultDesc": resultDesc,
        "ResponseData": List<dynamic>.from(responseData.map((x) => x.toJson())),
      };
}

class ResponseDatumAccounts {
  ResponseDatumAccounts({
    this.id,
    this.name,
    required this.type,
    this.balance,
    this.userId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.code,
    required this.bankingAcc,
    required this.responseDatumCategory,
  });

  int? id;
  String? name;
  Type type;
  int? balance;
  int? userId;
  dynamic? deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  int category;
  int? code;
  BankingAcc bankingAcc;
  Category responseDatumCategory;

  factory ResponseDatumAccounts.fromJson(Map<String, dynamic> json) =>
      ResponseDatumAccounts(
        id: json["id"],
        name: json["Name"],
        type: typeValues.map[json["Type"]]!,
        balance: json["Balance"],
        userId: json["user_id"],
        deletedAt: json["deleted_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        category: json["Category"],
        code: json["code"] == null ? null : json["code"],
        bankingAcc: bankingAccValues.map[json["BankingAcc"]]!,
        responseDatumCategory: Category.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Name": name,
        "Type": typeValues.reverse![type],
        "Balance": balance,
        "user_id": userId,
        "deleted_at": deletedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "Category": category,
        "code": code == null ? null : code,
        "BankingAcc": bankingAccValues.reverse![bankingAcc],
        "category": responseDatumCategory.toJson(),
      };
}

enum BankingAcc { N, Y }

final bankingAccValues = EnumValues({"N": BankingAcc.N, "Y": BankingAcc.Y});

class Category {
  Category({
    this.id,
    this.userId,
    this.name,
    required this.createdAt,
    required this.updatedAt,
    this.code,
  });

  int? id;
  int? userId;
  String? name;
  DateTime createdAt;
  DateTime updatedAt;
  int? code;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        userId: json["user_id"],
        name: json["Name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "Name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "code": code,
      };
}

enum Type { C }

final typeValues = EnumValues({"C": Type.C});

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
