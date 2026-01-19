class MembershipPackage {
  final int id;
  final String name;
  final String description;
  final int price;
  final String type;
  final int duration;
  final String durationUnit;
  final List<String> features;

  MembershipPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.duration,
    required this.durationUnit,
    required this.features,
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) => MembershipPackage(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    duration: json["duration"],
    durationUnit: json["durationUnit"],
    features: List<String>.from(json["features"].map((x) => x)),
    type: json["type"] ?? 'UNKNOWN',
  );

  String get formattedPrice {
    if (price == 0) return 'Free';
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND';
  }
}