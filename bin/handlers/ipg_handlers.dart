import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import '../naji_response.dart';
import '../clients/ipg_client.dart';
import '../db/service_repository.dart';
import '../db/invoice_repository.dart';
import '../models/invoice_model.dart';
import '../constants.dart';
import 'naji_handlers.dart';

const failureHtml = '''
      <!DOCTYPE html>
    <html>
      <head>
        <title>نتیجه تراکنش</title>
        <style>
          body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
          .container { display: flex; flex-direction: column; justify-content: center; align-items: center; }
          .button { margin-top: 50px; padding: 10px 20px; font-size: 18px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }
        </style>
      </head>
      <body>
          <h1>عملیات ناموفق</h1>
          <p>تراکنش انجام نشد. درصورت پرداخت، مبلغ کسر شده حداکثر تا 72 ساعت به حساب شما باز می گردد.</p>
      </body>
    </html>
    ''';

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
  final localInvoiceId = DateTime.now().microsecondsSinceEpoch;

  try {
    final response =
        await IpgNetworkModule.instance.dio.post('/v1/Token', data: {
      'merchantConfigurationId': Constants.merchantConfigurationId,
      'serviceTypeId': 1,
      'localInvoiceId': localInvoiceId,
      'amountInRials': amount,
      'localDate': localDate.data.toString(),
      'additionalData': '',
      "callbackURL":
          "http://emdad.behpardaz.net/payment-result?localInvoiceId=$localInvoiceId",
      "paymentId": "0"
    });
    if (response.statusCode.toString()[0] != '2') {
      return Response.ok(
          NajiResponse(resultCode: 1, failures: [
            'سرویس آسان پرداخت در دسترس نیست، پس از مدتی دوباره تلاش کنید'
          ], data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
    refId = response.data;
  } catch (e) {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: [
          'سرویس آسان پرداخت در دسترس نیست، پس از مدتی دوباره تلاش کنید'
        ], data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  InvoiceRepository.instance?.write(InvoiceData(
    refId: refId,
    userId: userId,
    licenseNumber: licenseNumber,
    plateNumber: plateNumber,
    serviceId: serviceId,
    localInvoiceId: localInvoiceId.toString(),
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
  final refId = request.url.queryParameters['refId'];
  final mobileNumber = request.url.queryParameters['mobileNumber'];

  if (refId == null) {
    return Response.notFound('یافت نشد RefId');
  }
//TODO: TEST and add mobile number
  final htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <title>انتقال به پرداخت...</title>
      </head>
      <body onload="document.forms['paymentForm'].submit()">
        <p>درحال انتقال به درگاه پرداخت...</p>
        <form id="paymentForm" method="POST" action="https://asan.shaparak.ir">
          <input type="hidden" name="RefId" value="$refId" />
          ${mobileNumber == null ? '' : '<input type="hidden" name="mobileap" value="$mobileNumber" />'}
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
    final tranResult = await IpgNetworkModule.instance.dio
        .get('/v1/TranResult', queryParameters: {
      'merchantConfigurationId': Constants.merchantConfigurationId,
      'localInvoiceId': int.parse(localInvoiceId ?? ''),
    });
    if (tranResult.statusCode == 472) {
      return Response.ok(failureHtml, headers: {
        HttpHeaders.contentTypeHeader: 'text/html',
      });
    }
    InvoiceRepository.instance?.update(
      tranResult.data['refID'],
      InvoiceData(
        ipgRefId: tranResult.data['refID'],
        rrn: tranResult.data['rrn'],
        payGateTranID: tranResult.data['payGateTranID'],
        amount: tranResult.data['amount'],
        cardNumber: tranResult.data['cardNumber'],
        payGateTranDate: tranResult.data['payGateTranDate'],
        serviceStatusCode: tranResult.data['serviceStatusCode'],
      ),
    );
    if (tranResult.data['serviceStatusCode'].toString() == '0') {
      //success
      final invoice =
          await InvoiceRepository.instance?.getById(localInvoiceId ?? '-1');
      if (invoice == null) {
        return Response.ok(
            NajiResponse(
                resultCode: 1,
                failures: ['خطای پایگاه داده'],
                data: {}).getJson(),
            headers: {"Content-Type": "application/json"});
      }
      final najiStatus = await doNajiRequest(invoice);
      if (najiStatus != 0) {
        ///-1 also comes here, which means HTTP result to naji services was NOT 200!
        //TODO: reverse, cancel
        //TODO: html failure

        return Response.ok(failureHtml, headers: {
          HttpHeaders.contentTypeHeader: 'text/html',
        });
      } else {
        final verifyResult =
            await IpgNetworkModule.instance.dio.post('/v1/Verify', data: {
          'merchantConfigurationId': Constants.merchantConfigurationId,
          'payGateTranId': int.parse(tranResult.data['payGateTranID']),
        });
        var successHtml = '''
    <!DOCTYPE html>
    <html>
      <head>
        <title>نتیجه تراکنش</title>
        <style>
          body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
          .container { display: flex; flex-direction: column; justify-content: center; align-items: center; }
          .button { margin-top: 50px; padding: 10px 20px; font-size: 18px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>عملیات موفق</h1>
          <p>تراکنش با موفقیت انجام شد</p>
          <a href="eks://emdad.behpardaz.net/payment-result?refId=${invoice.refId}" class="button">بازگشت به برنامه</a>
        </div>
      </body>
    </html>
    ''';
        return Response.ok(successHtml, headers: {
          HttpHeaders.contentTypeHeader: 'text/html',
        });
      }
    } else {
      //failure
      //TODO
      return Response.ok(failureHtml, headers: {
        HttpHeaders.contentTypeHeader: 'text/html',
      });
    }
  } catch (e) {
    //TODO: HTML failure for Asan Pardakht
    return Response.ok(failureHtml, headers: {
      HttpHeaders.contentTypeHeader: 'text/html',
    });
  }
}

Future<int> doNajiRequest(InvoiceData invoice) async {
  final Map<String, dynamic>? result;
  switch (invoice.serviceId) {
    case '1':
      result = await negativePoint(
        mobileNumber: invoice.mobileNumber!,
        nationalCode: invoice.nationalCode!,
        licenseNumber: invoice.licenseNumber!,
      );

    case '2':
      result = await licensePlates(
        mobileNumber: invoice.mobileNumber!,
        nationalCode: invoice.nationalCode!,
      );

    case '3':
      result = await drivingLicences(
        mobileNumber: invoice.mobileNumber!,
        nationalCode: invoice.nationalCode!,
      );

    case '4':
      result = await vehiclesViolations(
        mobileNumber: invoice.mobileNumber!,
        nationalCode: invoice.nationalCode!,
        plateNumber: invoice.plateNumber!,
      );

    case '5':
      result = await violationsAggregate(
        mobileNumber: invoice.mobileNumber!,
        nationalCode: invoice.nationalCode!,
        plateNumber: invoice.plateNumber!,
      );

    case '6':
      result = await vehiclesDocumentsStatus(
        mobileNumber: invoice.mobileNumber!,
        nationalCode: invoice.nationalCode!,
        plateNumber: invoice.plateNumber!,
      );
    default:
      result = null;
  }
  InvoiceRepository.instance?.update(
      invoice.refId ?? '-1', InvoiceData(najiResult: jsonEncode(result)));
  return result?['resultStatus'] ?? -1;
}

Future<Response> serviceResult(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? refId = body['refId'];
  if (refId == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['شناسه درخواست الزامی است، با پشتیبانی تماس بگیرید.'],
            data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final invoice = await InvoiceRepository.instance?.getByRefId(refId);
  if (invoice == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['فاکتور موردنظر یافت نشد'],
            data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  final json = jsonDecode(invoice.najiResult!);
  if (json == null || json == {}) {
    ///TESTING
    final najiStatus = await doNajiRequest(invoice);
    final readInvoice =
        await InvoiceRepository.instance?.getByRefId(invoice.refId ?? '');
    final newJson = jsonDecode(readInvoice!.najiResult!);
    if (newJson['resultStatus'] != 0) {
      return Response.ok(
          NajiResponse(resultCode: 1, failures: [
            newJson['resultStatusMessage'] ??
                'پاسخ مناسب از سرویس ناجی دریافت نشد.'
          ], data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
    return Response.ok(
        NajiResponse(resultCode: 0, failures: [], data: {
          'negativePoint': invoice.serviceId == '1' ? newJson : {},
          'licensePlates':
              invoice.serviceId == '2' ? jsonDecode(newJson['result']) : {},
          'drivingLicences':
              invoice.serviceId == '3' ? jsonDecode(newJson['result']) : {},
          'vehiclesViolations':
              invoice.serviceId == '4' ? jsonDecode(newJson['result']) : {},
          'violationsAggregate': invoice.serviceId == '5' ? newJson : {},
          'vehiclesDocumentsStatus': invoice.serviceId == '6' ? newJson : {},
        }).getJson(),
        headers: {"Content-Type": "application/json"});

    ///TESTING
    ///TODO: UNCOMMENT AND COMMENT TESTING ABOVE
    // return Response.ok(
    //     NajiResponse(
    //         resultCode: 1,
    //         failures: ['تراکنش انجام نشد. درصورت پرداخت، مبلغ کسر شده حداکثر تا 72 ساعت به حساب شما باز می گردد.'],
    //         data: {}).getJson(),
    //     headers: {"Content-Type": "application/json"});
  } else {
    if (json['resultStatus'] != 0) {
      return Response.ok(
          NajiResponse(resultCode: 0, failures: [
            json['resultStatusMessage'] ??
                'پاسخ مناسب از سرویس ناجی دریافت نشد.'
          ], data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
    return Response.ok(
        NajiResponse(resultCode: 0, failures: [], data: {
          'negativePoint': invoice.serviceId == '1' ? json : {},
          'licensePlates':
              invoice.serviceId == '2' ? jsonDecode(json['result']) : {},
          'drivingLicences':
              invoice.serviceId == '3' ? jsonDecode(json['result']) : {},
          'vehiclesViolations':
              invoice.serviceId == '4' ? jsonDecode(json['result']) : {},
          'violationsAggregate': invoice.serviceId == '5' ? json : {},
          'vehiclesDocumentsStatus': invoice.serviceId == '6' ? json : {},
        }).getJson(),
        headers: {"Content-Type": "application/json"});
  }
}
