// models/membership_subscription.dart
import 'membership_package.dart';

class MembershipSubscription {
  final int id;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final int? orderCode;
  final int? totalAmount;
  final MembershipPackage? membershipPackage;

  MembershipSubscription({
    required this.id,
    this.startDate,
    this.endDate,
    this.status,
    this.orderCode,
    this.totalAmount,
    this.membershipPackage,
  });

  factory MembershipSubscription.fromJson(Map<String, dynamic> json) {
    return MembershipSubscription(
      id: json['id'] != null ? json['id'] as int : 0, 
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'] != null ? json['status'] as String : 'UNKNOWN',
      orderCode: json['orderCode'] != null ? json['orderCode'] as int : 0,
      totalAmount: json['totalAmount'] != null ? json['totalAmount'] as int : 0,
      membershipPackage: json['membershipPackage'] != null
          ? MembershipPackage.fromJson(json['membershipPackage'])
          : null,
    );
  }
}
