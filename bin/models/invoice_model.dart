class InvoiceData {
  final int? id;

  //Needed for writing into database
  final String? refId, serviceId, plateNumber, licenseNumber, localInvoiceId,localDate;
  final String? userId;

  //Populated by triggers, not needed for writing
  final String? nationalCode, mobileNumber, serviceName;

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
      "localDate":localDate,
    };
  }
}
