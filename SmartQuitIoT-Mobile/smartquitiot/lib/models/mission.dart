class Mission {
  final int id;
  final String code;
  final String name;
  final String description;

  Mission({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
    );
  }
}
