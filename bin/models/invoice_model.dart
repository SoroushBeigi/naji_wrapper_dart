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
  final String? rrn,
      payGateTranID,
      amount,
      cardNumber,
      payGateTranDate,
      serviceStatusCode,ipgRefId;
  final String? najiResult;

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
    this.serviceStatusCode,
    this.najiResult,
    this.ipgRefId,
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
      "rrn": rrn,
      "payGateTranID": payGateTranID,
      "amount": amount,
      "cardNumber": cardNumber,
      "payGateTranDate": payGateTranDate,
      "serviceStatusCode": serviceStatusCode,
      "najiResult":najiResult,
      "ipgRefId":ipgRefId,
    };
  }
}
