class PaymentLinkData {
  final String bin;
  final String accountNumber;
  final String accountName;
  final int amount;
  final String description;
  final int orderCode;
  final String checkoutUrl;
  final String qrCode;

  PaymentLinkData({
    required this.bin,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.description,
    required this.orderCode,
    required this.checkoutUrl,
    required this.qrCode,
  });

  factory PaymentLinkData.fromJson(Map<String, dynamic> json) => PaymentLinkData(
    bin: json["bin"],
    accountNumber: json["accountNumber"],
    accountName: json["accountName"],
    amount: json["amount"],
    description: json["description"],
    orderCode: json["orderCode"],
    checkoutUrl: json["checkoutUrl"],
    qrCode: json["qrCode"],
  );
}