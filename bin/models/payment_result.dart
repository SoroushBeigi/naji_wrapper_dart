class Payment {
  final int amount;
  final String? resultPaymentDateTime;
  final String? message;
  final String? bankReferenceNo;
  final String? bankTraceNo;
  final String? tag1;

  Payment({
    required this.amount,
    required this.resultPaymentDateTime,
    this.message,
    this.bankReferenceNo,
    this.bankTraceNo,
    this.tag1,
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