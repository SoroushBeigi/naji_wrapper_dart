import 'dart:convert';

import 'package:shelf/shelf.dart';
import '../naji_response.dart';
import '../clients/ipg_client.dart';
import '../db_repository.dart';

Future<Response> time(Request request) async {
  final response = await IpgNetworkModule.instance.dio.get('/v1/Time');
  final najiResponse =
      NajiResponse(resultCode: 0, failures: [], data: response.data);
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> payment(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? plateNumber = body['plateNumber'];
  final String? licenseNumber = body['licenseNumber'];
  final String? id = body['id'];

  if (id == null) {
    final najiResponse = NajiResponse(
        resultCode: 1, failures: ['شناسه خدمت ناجی یافت نشد.'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final int amount = await ServiceRepository.instance?.getPrice(id) ?? 0;
  if (amount == 0) {
    final najiResponse =
        NajiResponse(resultCode: 1, failures: ['قیمت یافت نشد.'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final localDate = await IpgNetworkModule.instance.dio.get('/v1/Time');

  final response = await IpgNetworkModule.instance.dio.post('/v1/Token', data: {
    'merchantConfigurationId': 227609,
    'serviceTypeId': 1,
    'localInvoiceId': DateTime.now().millisecondsSinceEpoch,
    'amountInRials': amount,
    'localDate': localDate.data,
    'additionalData': '',
    "callbackURL": "eks://emdad.behpardaz.net/payment-result",
    "paymentId": "0"
  });
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    'refId': response.data,
    'callbackURL': 'eks://emdad.behpardaz.net/payment-result',
  });
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
  // final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
  //   "callbackURL": "eks://emdad.behpardaz.net/payment-result",
  //   "refId":"1d8cea8adb1ad17eb"
  // });
  // return Response.ok(najiResponse.getJson(),
  //     headers: {"Content-Type": "application/json"});
}
