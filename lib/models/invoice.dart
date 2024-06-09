class Invoice {
  int? id;

  String? localId;
  int storeId;
  int? soldBy;
  int cardCode;
  int objType;
  double docTotal;
  double totalPaid;
  double? cashGiven;
  double balance;
  double? change;
  int saleStatus;
  int? receiptNo;
  int? cancelled;
  DateTime? createdAt;

  Invoice(
      {this.id,
      this.localId,
      required this.storeId,
      required this.soldBy,
      required this.cardCode,
      required this.objType,
      required this.docTotal,
      required this.totalPaid,
      this.cashGiven,
      required this.balance,
      this.change,
      required this.saleStatus,
      this.receiptNo,
      this.cancelled,
      this.createdAt});

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        localId: json['local_id'],
        storeId: json['store_id'],
        soldBy: json['sold_by'],
        cardCode: json['card_code'],
        objType: json['obj_type'],
        docTotal: json['doc_total'].toDouble(),
        totalPaid: json['total_paid'].toDouble(),
        cashGiven: json['cash_given'].toDouble(),
        balance: json['balance'].toDouble(),
        change: json['change'].toDouble(),
        saleStatus: json['sale_status'],
        receiptNo: json['receipt_no'],
        cancelled: json['cancelled'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'local_id': localId,
        'store_id': storeId,
        'sold_by': soldBy,
        'card_code': cardCode,
        'obj_type': objType,
        'doc_total': docTotal,
        'total_paid': totalPaid,
        'cash_given': cashGiven,
        'balance': balance,
        'change': change,
        'sale_status': saleStatus,
        'receipt_no': receiptNo,
        'cancelled': cancelled,
        'created_at': createdAt?.toIso8601String(),
      };
}
