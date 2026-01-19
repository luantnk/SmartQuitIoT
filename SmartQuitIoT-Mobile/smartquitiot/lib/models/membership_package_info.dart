class MembershipPackageInfo {
  final int id;
  final String name;

  MembershipPackageInfo({required this.id, required this.name});

  factory MembershipPackageInfo.fromJson(Map<String, dynamic> json) => MembershipPackageInfo(
    id: json["id"],
    name: json["name"],
  );
}