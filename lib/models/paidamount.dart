class TotalAmountData {
  TotalAmountData({
    required this.totalAmount,
  });

  int totalAmount;

  factory TotalAmountData.fromJson(Map<String, dynamic> json) =>
      TotalAmountData(
        totalAmount: json["TotalAmount"],
      );

  Map<String, dynamic> toJson() => {
        "TotalAmount": totalAmount,
      };
}
