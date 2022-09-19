// To parse this JSON data, do
//
//     final depositPayment = depositPaymentFromJson(jsonString);

import 'dart:convert';

DepositPayment depositPaymentFromJson(String str) =>
    DepositPayment.fromJson(json.decode(str));

String depositPaymentToJson(DepositPayment data) => json.encode(data.toJson());

class DepositPayment {
  DepositPayment({
    required this.odlnId,
    required this.docDate,
    required this.totalPaid,
    required this.payments,
  });

  int odlnId;
  DateTime docDate;
  int totalPaid;
  List<PaymentList> payments;

  factory DepositPayment.fromJson(Map<String, dynamic> json) => DepositPayment(
        odlnId: json["odln_id"],
        docDate: DateTime.parse(json["DocDate"]),
        totalPaid: json["total_paid"],
        payments: List<PaymentList>.from(
            json["payments"].map((x) => PaymentList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "odln_id": odlnId,
        "DocDate":
            "${docDate.year.toString().padLeft(4, '0')}-${docDate.month.toString().padLeft(2, '0')}-${docDate.day.toString().padLeft(2, '0')}",
        "total_paid": totalPaid,
        "payments": List<dynamic>.from(payments.map((x) => x.toJson())),
      };
}

class PaymentList {
  PaymentList({
    required this.oACTSId,
    required this.sumApplied,
    required this.paymentRemarks,
  });

  int oACTSId;
  int sumApplied;
  String paymentRemarks;

  factory PaymentList.fromJson(Map<String, dynamic> json) => PaymentList(
        oACTSId: json["o_a_c_t_s_id"],
        sumApplied: json["SumApplied"],
        paymentRemarks: json["PaymentRemarks"],
      );

  Map<String, dynamic> toJson() => {
        "o_a_c_t_s_id": oACTSId,
        "SumApplied": sumApplied,
        "PaymentRemarks": paymentRemarks,
      };
}
