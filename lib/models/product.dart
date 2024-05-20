// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  Product({
    required this.resultState,
    required this.resultCode,
    required this.resultDesc,
    required this.responseData,
  });

  bool resultState;
  int resultCode;
  String resultDesc;
  List<ResponseDatum> responseData;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        resultState: json["ResultState"],
        resultCode: json["ResultCode"],
        resultDesc: json["ResultDesc"],
        responseData: List<ResponseDatum>.from(
            json["ResponseData"].map((x) => ResponseDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResultState": resultState,
        "ResultCode": resultCode,
        "ResultDesc": resultDesc,
        "ResponseData": List<dynamic>.from(responseData.map((x) => x.toJson())),
      };
}

class ResponseDatum {
  ResponseDatum({
    required this.id,
    this.name,
    required this.availableQty,
    required this.sellingPrice,
    required this.o_p_l_n_s_id,
    this.itm1,
    this.industry,
    this.brand,
  });

  dynamic id;
  String? name;
  dynamic availableQty;
  double sellingPrice;
  dynamic o_p_l_n_s_id;
  dynamic itm1;
  dynamic industry;
  dynamic brand;

  factory ResponseDatum.fromJson(Map<String, dynamic> json) => ResponseDatum(
        id: json["id"],
        name: json["Name"],
        itm1: json["itm1"],
        industry: json["industry"],
        brand: json["brand"],
        availableQty: json['availableQty'],
        sellingPrice: json['sellingPrice'],
        o_p_l_n_s_id: json['o_p_l_n_s_id'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Name": name,
        "itm1": itm1,
        "industry": industry,
        "brand": brand,
        "availableQty": availableQty,
        "sellingPrice": sellingPrice,
        "o_p_l_n_s_id": o_p_l_n_s_id
      };

  Map<String, dynamic> responseDatumToJson(dynamic instance) =>
      <String, dynamic>{
        'id': instance.id,
        'name': instance.name,
        'itm1': instance.itm1,
        'industry': instance.industry,
        'brand': instance.brand,
        'availableQty': instance.availableQty,
        'sellingPrice': instance.sellingPrice,
        'o_p_l_n_s_id': instance.o_p_l_n_s_id,
      };
}
