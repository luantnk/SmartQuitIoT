import 'dart:convert';

import '../membership_package.dart';

MembershipApiResponse membershipApiResponseFromJson(String str) => MembershipApiResponse.fromJson(json.decode(str));

class MembershipApiResponse {
  final bool success;
  final String message;
  final List<MembershipPackage> data;
  final int code;
  final int timestamp;

  MembershipApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory MembershipApiResponse.fromJson(Map<String, dynamic> json) => MembershipApiResponse(
    success: json["success"],
    message: json["message"],
    data: List<MembershipPackage>.from(json["data"].map((x) => MembershipPackage.fromJson(x))),
    code: json["code"],
    timestamp: json["timestamp"],
  );
}