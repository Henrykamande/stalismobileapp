class Customer {
  int? id;
  String? name;
  String? phoneNumber;
  String? email;
  int? subscriberId;

  Customer({
    this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.subscriberId
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['Name'],
    phoneNumber: json['phoneNumber'],
    email: json['email'],
    subscriberId: json['subscriber_id']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'Name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'subscriber_id': subscriberId,
  };
}
