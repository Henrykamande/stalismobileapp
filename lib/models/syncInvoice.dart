import 'package:testproject/models/SyncPayment.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/sycsalerows.dart';

class SyncInvoice {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  int storeId;
  int? soldBy;
  int cardCode;
  int objType;
  double docTotal;
  double totalPaid;
  double cashGiven;
  double balance;
  double change;
  int saleStatus;
  int receiptNo;
  int cancelled;
  List<SyncPayment> payments;
  List<SyncSaleRow> rows;

  SyncInvoice({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.storeId,
    this.soldBy,
    required this.cardCode,
    required this.objType,
    required this.docTotal,
    required this.totalPaid,
    required this.cashGiven,
    required this.balance,
    required this.change,
    required this.saleStatus,
    required this.receiptNo,
    required this.cancelled,
    required this.payments,
    required this.rows,
  });

  factory SyncInvoice.fromJson(Map<String, dynamic> json) {
    return SyncInvoice(
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
      //localId: json['local_id'],
      storeId: json['store_id'],
      soldBy: json['sold_by'],
      cardCode: json['card_code'],
      objType: json['obj_type'],
      docTotal: json['doc_total'],
      totalPaid: json['total_paid'],
      cashGiven: json['cash_given'] ?? 0,
      balance: json['balance'],
      change: json['change'] ?? 0,
      saleStatus: json['sale_status'],
      receiptNo: json['receipt_no'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      payments: List<SyncPayment>.from(
          (json['payments'] ?? []).map((x) => x as SyncPayment)),
      rows: List<SyncSaleRow>.from(
          (json['rows'] ?? []).map((x) => x as SyncSaleRow)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
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
      'payments': List<dynamic>.from(payments.map((x) => x.toJson())),
      'rows': List<dynamic>.from(rows.map((x) => x.toJson())),
    };
  }
}
