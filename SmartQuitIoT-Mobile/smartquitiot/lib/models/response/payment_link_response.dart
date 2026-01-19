// lib/models/payment_link_data.dart

import 'dart:convert';

import '../payment_link_data.dart';

// === ĐÂY LÀ HÀM BẠN ĐANG THIẾU ===
// Hàm này nhận một chuỗi JSON và trả về một đối tượng PaymentLinkResponse
PaymentLinkResponse paymentLinkResponseFromJson(String str) => PaymentLinkResponse.fromJson(json.decode(str));

// Class này đại diện cho toàn bộ cấu trúc JSON trả về
class PaymentLinkResponse {
  final bool success;
  final String message;
  final PaymentLinkData data;
  final int code;

  PaymentLinkResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
  });

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) => PaymentLinkResponse(
    success: json["success"],
    message: json["message"],
    data: PaymentLinkData.fromJson(json["data"]),
    code: json["code"],
  );
}