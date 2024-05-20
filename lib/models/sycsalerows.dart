class SyncSaleRow {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  int storeId;
  int invoiceId;
  int cardCode;
  String rowId;
  int productId;
  String name;
  int uomEntry;
  double quantity;
  double price;
  double lineTotal;
  int soldBy;
  int receiptNo;
  int cancelled;

  SyncSaleRow({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.storeId,
    required this.invoiceId,
    required this.cardCode,
    required this.rowId,
    required this.productId,
    required this.name,
    required this.uomEntry,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    required this.soldBy,
    required this.receiptNo,
    required this.cancelled,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      ''
          'createdAt': createdAt != null ? createdAt!.toIso8601String() : '',
      'updatedAt': updatedAt != null ? updatedAt!.toIso8601String() : '',
      'deletedAt': deletedAt != null ? deletedAt!.toIso8601String() : '',
      'store_id': storeId,
      'invoiceId': invoiceId,
      'cardCode': cardCode,
      'rowId': rowId,
      'productId': productId,
      'name': name,
      'uomEntry': uomEntry,
      'quantity': quantity,
      'price': price,
      'lineTotal': lineTotal,
      'soldBy': soldBy,
      'receiptNo': receiptNo,
      'cancelled': cancelled,
    };
  }

  static SyncSaleRow fromJson(Map<String, dynamic> json) {
    return SyncSaleRow(
      id: json['id'],
      storeId: json['store_id'],
      invoiceId: json['invoice_id'],
      cardCode: json['card_code'],
      rowId: json['row_id'],
      productId: json['product_id'],
      name: json['name'],
      uomEntry: json['uom_entry'] ?? 0,
      quantity: json['quantity'],
      price: json['price'],
      lineTotal: json['line_total'],
      soldBy: json['sold_by'] ?? 0,
      receiptNo: json['receipt_no'],
      cancelled: json['cancelled'],
    );
  }
}
