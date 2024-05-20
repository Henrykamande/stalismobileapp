class SyncPayment {
  SyncPayment(
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

  factory SyncPayment.fromJson(Map<String, dynamic> json) => SyncPayment(
      recieptNo: json["reciept_no"],
      invoiceId: json['invoice_id'],
      soldBy: json['soldBy'],
      cardCode: json['cardCode'],
      storeId: json['store_id'],
      sumApplied: json["SumApplied"],
      accountId: json["account_id"],
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
