// To parse this JSON data, do
//
//     final posSale = posSaleFromJson(jsonString);

import 'dart:convert';

PosSale posSaleFromJson(String str) => PosSale.fromJson(json.decode(str));

String posSaleToJson(PosSale data) => json.encode(data.toJson());

class PosSale {
  PosSale(
      {required this.objType,
      required this.docNum,
      this.cardCode,
      required this.docTotal,
      required this.balance,
      this.ref1,
      this.ref2,
      this.driver,
      this.saleType,
      this.pickedBy,
      this.customerName,
      required this.docDate,
      required this.discSum,
      required this.payments,
      required this.rows,
      required this.totalPaid,
      required this.userName,
      this.soldBy});

  int objType;
  int? soldBy;
  int docNum;
  int? cardCode;
  int? driver;
  int? saleType;
  double docTotal;
  double balance;
  String? ref2;
  String? ref1;
  String? pickedBy;
  String? customerName;
  DateTime docDate;
  int discSum;
  List<Payment> payments;
  List<SaleRow> rows;
  double totalPaid;
  String userName;

  factory PosSale.fromJson(Map<String, dynamic> json) => PosSale(
        soldBy: json['soldBy'],
        objType: json["ObjType"],
        driver: json["driver"],
        saleType: json["saleType"],
        pickedBy: json["pickedBy"],
        ref2: json['ref2'],
        docNum: json["DocNum"],
        cardCode: json["CardCode"],
        docTotal: json["DocTotal"],
        balance: json["Balance"],
        ref1: json["ref1"],
        docDate: DateTime.parse(json["DocDate"]),
        discSum: json["DiscSum"],
        payments: List<Payment>.from(
            json["payments"].map((x) => Payment.fromJson(x))),
        rows: List<SaleRow>.from(json["rows"].map((x) => SaleRow.fromJson(x))),
        totalPaid: json["totalPaid"],
        userName: json["userName"],
        customerName: json['customerName'],
      );

  Map<String, dynamic> toJson() => {
        "ObjType": objType,
        "drive": driver,
        "saleType": saleType,
        "DocNum": docNum,
        "pickedBy": pickedBy,
        "CardCode": cardCode,
        "DocTotal": docTotal,
        "Balance": balance,
        "ref1": ref1,
        "ref2": ref2,
        "DocDate":
            "${docDate.year.toString().padLeft(4, '0')}-${docDate.month.toString().padLeft(2, '0')}-${docDate.day.toString().padLeft(2, '0')}",
        "DiscSum": discSum,
        "payments": List<dynamic>.from(payments.map((x) => x.toJson())),
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
        "TotalPaid": totalPaid,
        "userName": userName,
        "customerName": customerName,
      };
}

class Payment {
  Payment(
      {this.sumApplied,
      required this.accountId,
      this.name,
      this.paymentRemarks,
      this.cardCode,
      this.soldBy,
      this.recieptNo,
      this.invoiceId,
      this.storeId});

  int? sumApplied;
  int? recieptNo;
  int? cardCode;
  int accountId;
  String? name;
  int? storeId;
  int? soldBy;
  int? invoiceId;
  String? paymentRemarks;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
      recieptNo: json["reciept_no"],
      invoiceId: json['invoice_id'],
      soldBy: json['soldBy'],
      cardCode: json['cardCode'],
      storeId: json['store_id'],
      sumApplied: json["SumApplied"],
      accountId: json["o_a_c_t_s_id"],
      name: json['name'],
      paymentRemarks: json['paymentRemarks']);

  Map<String, dynamic> toJson() => {
        "receipt_no": recieptNo,
        "invoice_id": invoiceId,
        "sold_by": soldBy,
        "card_code": cardCode,
        "store_id": storeId,
        "Sum_applied": sumApplied,
        "account_id": accountId,
        "payment_remarks": paymentRemarks,
      };
}

class SaleRow {
  SaleRow(
      {this.storeId,
      this.cancelled,
      this.gasType,
      this.name,
      this.ref1,
      this.oPLNSId,
      this.price,
      this.quantity,
      this.cardCode,
      this.invoiceId,
      this.uomEntry,
      required this.oITMSId,
      this.discSum,
      required this.lineTotal,
      required this.lineNum,
      this.commission,
      this.taxId,
      this.taxRate,
      this.taxAmount,
      this.receiptNo});
  String? name;
  int? invoiceId;
  int? storeId;
  int? receiptNo;
  int? cardCode;
  String? gasType;
  int? oPLNSId;
  double? price;
  int? quantity;
  dynamic uomEntry;
  int oITMSId;
  int? discSum;
  double lineTotal;
  int lineNum;
  int? commission;
  int? cancelled;
  dynamic? taxId;
  dynamic? taxRate;
  dynamic? taxAmount;
  String? ref1;

  factory SaleRow.fromJson(Map<String, dynamic> json) => SaleRow(
      storeId: json['store_id'],
      cardCode: json['cardCode'],
      name: json["name"],
      invoiceId: json['invoice_id'],
      oPLNSId: json["o_p_l_n_s_id"],
      price: json["Price"],
      quantity: json["Quantity"],
      uomEntry: json["UomEntry"],
      oITMSId: json["o_i_t_m_s_id"],
      discSum: json["DiscSum"],
      lineTotal: json["LineTotal"],
      lineNum: json["LineNum"],
      commission: json["Commission"],
      taxId: json["TaxId"],
      cancelled: json['cancelled'],
      taxRate: json["TaxRate"],
      taxAmount: json["TaxAmount"],
      ref1: json["ref1"],
      receiptNo: json['receipt_no'],
      gasType: json['gasType']);

  Map<String, dynamic> toJson() => {
        "name": name,
        "store_id": storeId,
        "invoice_id": invoiceId,
        "Price": price,
        "quantity": quantity,
        "uom_entry": uomEntry,
        "product_id": oITMSId,
        //"DiscSum": discSum,
        "line_total": lineTotal,
        "row_id": lineNum,
        //"Commission": commission,
        //"TaxId": taxId,
        //"TaxRate": taxRate,
        // "TaxAmount": taxAmount,
        //"ref1": ref1,
        //"gasType": gasType,
        "receipt_no": receiptNo,
        "cancelled": cancelled,
        "card_code": cardCode,
      };
}
