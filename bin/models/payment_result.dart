class Payment {
  final String? amount;
  final String? resultPaymentDateTime;
  final String? message;
  final String? bankReferenceNo;
  final String? bankTraceNo;
  final String? callbackUrl;

  Payment({
    required this.amount,
    required this.resultPaymentDateTime,
    this.message,
    this.bankReferenceNo,
    this.bankTraceNo,
    this.callbackUrl,
  });
}

class PaymentResult {
  final String status;
  final String statusTitle;
  final Payment? payment;

  PaymentResult({
    required this.status,
    required this.statusTitle,
    this.payment,
  });
}