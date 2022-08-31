// To parse this JSON data, do
//
//     final macAddress = macAddressFromJson(jsonString);

import 'dart:convert';

MacAddress macAddressFromJson(String str) =>
    MacAddress.fromJson(json.decode(str));

String macAddressToJson(MacAddress data) => json.encode(data.toJson());

class MacAddress {
  MacAddress({
    this.resultState,
    this.resultCode,
    this.resultDesc,
    required this.responseData,
  });

  bool? resultState;
  int? resultCode;
  String? resultDesc;
  String responseData;

  factory MacAddress.fromJson(Map<String, dynamic> json) => MacAddress(
        resultState: json["ResultState"],
        resultCode: json["ResultCode"],
        resultDesc: json["ResultDesc"],
        responseData: json["ResponseData"],
      );

  Map<String, dynamic> toJson() => {
        "ResultState": resultState,
        "ResultCode": resultCode,
        "ResultDesc": resultDesc,
        "ResponseData": responseData,
      };
}
