class Product {
  int? id;
  String? name;
  String? barcode;
  String? description;
  String? itemType;
  double? buyingPrice;
  double? sellingPrice;
  double? leastPrice;
  double? availableQty;
  int? hasUom;
  int? subscriberId;

  Product({
    this.id,
    required this.name,
    this.barcode,
    this.description,
    this.itemType,
    this.buyingPrice,
    this.sellingPrice,
    this.leastPrice,
    this.availableQty,
    this.hasUom,
    this.subscriberId
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      id: json['id'],
      name: json['Name'],
      barcode: json['BarCode'],
      itemType: json['ItemType'],
      buyingPrice: json['BuyingPrice'],
      sellingPrice: json['SellingPrice'],
      leastPrice: json['LeastPrice'],
      availableQty: json['AvailableQty'],
      hasUom: json['HasUom'],
      subscriberId: json['subscriber_id']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'Name': name,
    'BarCode': barcode,
    'ItemType': itemType,
    'BuyingPrice': buyingPrice,
    'SellingPrice': sellingPrice,
    'LeastPrice': leastPrice,
    'AvailableQty': availableQty,
    'HasUom': hasUom,
    'subscriber_id': subscriberId,
  };
}
