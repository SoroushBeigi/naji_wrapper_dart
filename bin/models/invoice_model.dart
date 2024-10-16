class InvoiceData {
  final int? id;

  //Needed for writing into database
  final String? refId,
      serviceId,
      plateNumber,
      licenseNumber,
      localInvoiceId,
      localDate,
      name;
  final String? userId, callbackUrl;

  //Populated by triggers, not needed for writing
  final String? nationalCode, mobileNumber, serviceName;

  //Comes after callback
  final String? rrn,
      payGateTranID,
      amount,
      cardNumber,
      payGateTranDate,
      serviceStatusCode;

  final String? najiResult,
      requestpay_req_json,
      requestpay_res_json,
      requestpay_msg,
      resultpay_res_json,
      resultpay_msg,
      verify_req_json,
      verify_res_json,
      settle_res_json,
      settle_req_json,
      verify_msg,
      settle_msg;

  final int? requestpay_status,
      requestpay_result,
      resultpay_status,
      resultpay_result,
      verify_status,
      settle_status,
      verify_result,
      settle_result,
      payment_result;

  final DateTime? requestpay_datetime,
      resultpay_datetime,
      verify_datetime,
      settle_datetime;

  InvoiceData({
    this.payment_result,
    this.callbackUrl,
    this.settle_res_json,
    this.settle_req_json,
    this.settle_msg,
    this.settle_status,
    this.settle_result,
    this.settle_datetime,
    this.verify_req_json,
    this.verify_res_json,
    this.verify_status,
    this.verify_result,
    this.verify_msg,
    this.verify_datetime,
    this.requestpay_status,
    this.requestpay_result,
    this.resultpay_status,
    this.resultpay_result,
    this.requestpay_req_json,
    this.requestpay_res_json,
    this.requestpay_msg,
    this.resultpay_res_json,
    this.resultpay_msg,
    this.requestpay_datetime,
    this.resultpay_datetime,
    this.id,
    this.name,
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
  });

  Map<String, dynamic> getFields() {
    return {
      "id": id,
      "name": name,
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
      "najiResult": najiResult,
      "requestpay_req_json": requestpay_req_json,
      "requestpay_res_json": requestpay_res_json,
      "requestpay_msg": requestpay_msg,
      "resultpay_res_json": resultpay_res_json,
      "resultpay_msg": resultpay_msg,
      "requestpay_datetime": requestpay_datetime,
      "resultpay_datetime": resultpay_datetime,
      "verify_req_json": verify_req_json,
      "verify_res_json": verify_res_json,
      "verify_status": verify_status,
      "verify_result": verify_result,
      "verify_msg": verify_msg,
      "verify_datetime": verify_datetime,
      "settle_req_json": settle_req_json,
      "settle_res_json": settle_res_json,
      "settle_status": settle_status,
      "settle_result": settle_result,
      "settle_msg": settle_msg,
      "settle_datetime": settle_datetime,
      "callbackUrl": callbackUrl,
      "payment_result": payment_result,
    };
  }
}
