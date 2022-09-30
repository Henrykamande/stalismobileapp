// To parse this JSON data, do
//
//     final itm4 = itm4FromJson(jsonString);

import 'dart:convert';

Itm4 itm4FromJson(String str) => Itm4.fromJson(json.decode(str));

String itm4ToJson(Itm4 data) => json.encode(data.toJson());

class Itm4 {
  Itm4({
    required this.id,
    required this.oPLNSId,
    required this.oITMSId,
    required this.sellingPrice,
    this.createdAt,
    this.updatedAt,
    this.lowerLimit,
    this.fullGas,
    this.refill,
    this.pricelist,
  });

  int id;
  int oPLNSId;
  int oITMSId;
  int sellingPrice;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? lowerLimit;
  int? fullGas;
  int? refill;
  Pricelist? pricelist;

  factory Itm4.fromJson(Map<String, dynamic> json) => Itm4(
        id: json["id"],
        oPLNSId: json["o_p_l_n_s_id"],
        oITMSId: json["o_i_t_m_s_id"],
        sellingPrice: json["SellingPrice"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        lowerLimit: json["LowerLimit"],
        fullGas: json["fullGas"],
        refill: json["refill"],
        pricelist: Pricelist.fromJson(json["pricelist"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "o_p_l_n_s_id": oPLNSId,
        "o_i_t_m_s_id": oITMSId,
        "SellingPrice": sellingPrice,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "LowerLimit": lowerLimit,
        "fullGas": fullGas,
        "refill": refill,
        "pricelist": pricelist!.toJson(),
      };
}

class Pricelist {
  Pricelist({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userId;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  factory Pricelist.fromJson(Map<String, dynamic> json) => Pricelist(
        id: json["id"],
        userId: json["user_id"],
        name: json["Name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "Name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
