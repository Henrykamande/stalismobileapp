class Account {
  int? id;
  String? name;
  int? subscriberId;

  Account({
    this.id,
    required this.name,
    this.subscriberId
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
      id: json['id'],
      name: json['Name'],
      subscriberId: json['subscriber_id']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'Name': name,
    'subscriber_id': subscriberId,
  };
}
