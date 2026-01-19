import 'dart:convert';

import 'membership_package_info.dart';

List<PlanOption> planOptionFromJson(String str) => List<PlanOption>.from(json.decode(str).map((x) => PlanOption.fromJson(x)));

class PlanOption {
  final int planPrice;
  final int planDuration;
  final String planDurationUnit;
  final MembershipPackageInfo membershipPackage;

  PlanOption({
    required this.planPrice,
    required this.planDuration,
    required this.planDurationUnit,
    required this.membershipPackage,
  });

  factory PlanOption.fromJson(Map<String, dynamic> json) => PlanOption(
    planPrice: json["planPrice"],
    planDuration: json["planDuration"],
    planDurationUnit: json["planDurationUnit"],
    membershipPackage: MembershipPackageInfo.fromJson(json["membershipPackage"]),
  );
}