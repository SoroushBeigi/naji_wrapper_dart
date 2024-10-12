class InvoiceData {
  final int? id;
  final String? refId,
      serviceId,
      nationalCode,
      mobileNumber,
      plateNumber,
      licenseNumber;


  InvoiceData({
    this.id,
    this.refId,
    this.serviceId,
    this.nationalCode,
    this.mobileNumber,
    this.plateNumber,
    this.licenseNumber,
  });

  Map<String,dynamic> getFields() {
    return {
      "id": id,
      "refId": refId,
      "serviceId": serviceId,
      "nationalCode": nationalCode,
      "mobileNumber": mobileNumber,
      "plateNumber": plateNumber,
      "licenseNumber": licenseNumber,
    };
  }
}
