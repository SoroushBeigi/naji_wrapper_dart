import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import '../naji_response.dart';
import '../clients/ipg_client.dart';
import '../db/service_repository.dart';
import '../db/invoice_repository.dart';
import '../models/invoice_model.dart';
import '../constants.dart';

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

  final String? plateNumber = body['plateNumber'];
  final String? licenseNumber = body['licenseNumber'];
  final String? userId = body['userId'];
  final String? serviceId = body['serviceId'];

  if (serviceId == null) {
    final najiResponse = NajiResponse(
        resultCode: 1, failures: ['شناسه خدمت ناجی یافت نشد.'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }
  if (userId == null) {
    final najiResponse = NajiResponse(
        resultCode: 1, failures: ['شناسه کاربر یافت نشد.'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final int amount = await ServiceRepository.instance?.getPrice(serviceId) ?? 0;
  if (amount == 0) {
    final najiResponse =
        NajiResponse(resultCode: 1, failures: ['قیمت یافت نشد.'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final localDate = await IpgNetworkModule.instance.dio.get('/v1/Time');
  final String refId;
  final String localInvoiceId =
      DateTime.now().microsecondsSinceEpoch.toString();

  try {
    final response =
        await IpgNetworkModule.instance.dio.post('/v1/Token', data: {
      'merchantConfigurationId': Constants.merchantConfigurationId,
      'serviceTypeId': 1,
      'localInvoiceId': localInvoiceId,
      'amountInRials': amount,
      'localDate': localDate.data,
      'additionalData': '',
      "callbackURL":
          "http://${Constants.baseUrl}:${Constants.port}/callback?localInvoiceId=$localInvoiceId",
      "paymentId": "0"
    });
    if (response.statusCode.toString()[0] != '2') {
      return Response.ok(
          NajiResponse(
              resultCode: 1,
              failures: ['خطای سرویس آسان پرداخت'],
              data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
    refId = response.data;
  } catch (e) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['خطای سرویس آسان پرداخت'],
            data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  InvoiceRepository.instance?.write(InvoiceData(
    refId: refId,
    userId: userId,
    licenseNumber: licenseNumber,
    plateNumber: plateNumber,
    serviceId: serviceId,
    localInvoiceId: localInvoiceId,
    localDate: localDate.data,
  ));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    'refId': refId,
    'callbackURL':
        'eks://emdad.behpardaz.net/payment-result?localInvoiceId=$localInvoiceId',
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

Future<Response> paymentGateway(Request request) async {
  var refId = request.url.queryParameters['refId'];

  if (refId == null) {
    return Response.notFound('یافت نشد RefId');
  }
//TODO: TEST and add mobile number
  var htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <title>انتقال به پرداخت...</title>
      </head>
      <body onload="document.forms['paymentForm'].submit()">
        <p>درحال انتقال به درگاه پرداخت...</p>
        <form id="paymentForm" method="POST" action="https://asan.shaparak.ir">
          <input type="hidden" name="RefId" value="$refId" />
        </form>
      </body>
    </html>
    ''';

  return Response.ok(htmlContent, headers: {
    HttpHeaders.contentTypeHeader: 'text/html',
  });
}

Future<Response> callback(Request request) async {
  final localInvoiceId = request.url.queryParameters['localInvoiceId'];
  try {
    final tranResult =
        await IpgNetworkModule.instance.dio.post('/v1/TranResult', data: {
      'merchantConfigurationId': Constants.merchantConfigurationId,
      'localInvoiceId': localInvoiceId,
    });
    InvoiceRepository.instance?.update(
      tranResult.data['refID'],
      InvoiceData(
        rrn: tranResult.data['rrn'],
        payGateTranID: tranResult.data['payGateTranID'],
        amount: tranResult.data['amount'],
        cardNumber: tranResult.data['cardNumber'],
        payGateTranDate: tranResult.data['payGateTranDate'],
      ),
    );
    return Response.ok({}, headers: {});
  } catch (e) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['خطای سرویس آسان پرداخت'],
            data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }
}
