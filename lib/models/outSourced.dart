import 'dart:convert';

class OurSourced {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  int storeId;
  int? invoiceId;
  int cardCode;
  String rowId;
  String name;
  String? uomName;
  double quantity;
  double buyingPrice;
  double price;
  double lineTotal;
  int? soldBy;
  int? receiptNo;
  int? cancelled;

  OurSourced({
    this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.storeId,
    this.invoiceId,
    required this.cardCode,
    required this.rowId,
    required this.name,
    this.uomName,
    required this.quantity,
    required this.buyingPrice,
    required this.price,
    required this.lineTotal,
    this.soldBy,
    this.receiptNo,
    this.cancelled,
  });

  factory OurSourced.fromJson(Map<String, dynamic> json) {
    return OurSourced(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      storeId: json['store_id'],
      invoiceId: json['invoice_id'],
      cardCode: json['card_code'],
      rowId: json['row_id'],
      name: json['name'],
      uomName: json['uom_name'],
      quantity: json['quantity'],
      buyingPrice: json['buying_price'],
      price: json['price'],
      lineTotal: json['line_total'],
      soldBy: json['sold_by'],
      receiptNo: json['receipt_no'],
      cancelled: json['cancelled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'store_id': storeId,
      'invoice_id': invoiceId,
      'card_code': cardCode,
      'row_id': rowId,
      'name': name,
      'uom_name': uomName,
      'quantity': quantity,
      'buying_price': buyingPrice,
      'price': price,
      'line_total': lineTotal,
      'sold_by': soldBy,
      'receipt_no': receiptNo,
      'cancelled': cancelled,
    };
  }
}
