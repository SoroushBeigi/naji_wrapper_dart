class InvoiceData {
  final int? id;

  //Needed for writing into database
  final String? refId,
      serviceId,
      plateNumber,
      licenseNumber,
      localInvoiceId,
      localDate;
  final String? userId;

  //Populated by triggers, not needed for writing
  final String? nationalCode, mobileNumber, serviceName;

  //Comes after callback
  final String? rrn, payGateTranID, amount, cardNumber,payGateTranDate;

  InvoiceData({
    this.id,
    this.userId,
    this.refId,
    this.serviceId,
    this.nationalCode,
    this.mobileNumber,
    this.plateNumber,
    this.licenseNumber,
    this.serviceName,
    this.localInvoiceId,
    this.localDate,
    this.rrn,
    this.payGateTranID,
    this.amount,
    this.cardNumber,
    this.payGateTranDate,
  });

  Map<String, dynamic> getFields() {
    return {
      "id": id,
      "refId": refId,
      "userId": userId,
      "serviceId": serviceId,
      "serviceName": serviceName,
      "nationalCode": nationalCode,
      "mobileNumber": mobileNumber,
      "plateNumber": plateNumber,
      "licenseNumber": licenseNumber,
      "localInvoiceId": localInvoiceId,
      "localDate": localDate,
      "rrn":rrn,
      "payGateTranID":payGateTranID,
      "amount":amount,
      "cardNumber":cardNumber,
      "payGateTranDate":payGateTranDate,
    };
  }
}
