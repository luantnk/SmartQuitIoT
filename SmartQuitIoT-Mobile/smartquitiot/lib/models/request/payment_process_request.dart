// models/request/payment_process_request.dart
class PaymentProcessRequest {
  final String code;
  final String id;
  final int orderCode;
  final bool cancel;
  final String status;

  PaymentProcessRequest({
    required this.code,
    required this.id,
    required this.orderCode,
    required this.cancel,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'id': id,
      'orderCode': orderCode,
      'cancel': cancel,
      'status': status,
    };
  }

  factory PaymentProcessRequest.fromQueryParams(Map<String, dynamic> params) {
    return PaymentProcessRequest(
      code: params['code'] ?? '',
      id: params['id'] ?? '',
      orderCode: int.tryParse(params['orderCode']?.toString() ?? '0') ?? 0,
      cancel: params['cancel']?.toString().toLowerCase() == 'true',
      status: params['status'] ?? 'UNKNOWN',
    );
  }
}
