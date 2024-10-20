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
import '../utils/date_converter.dart';
import '../utils/result_mapper.dart';
import '../models/payment_result.dart';

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

String generatePaymentHtml(PaymentResult paymentResult) {
  return '''
  <html>
  <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link rel="stylesheet" href="~/css/site.css" type="text/css" />
  </head>
  <body>
      <div class="payment-details">
          <div id="resultFrame">
              <div id="header-payment" class="${paymentResult.status
      .toLowerCase()}">
                  <span>${paymentResult.statusTitle}</span>
              </div>
              <div class="body-payment">
                  <div class="field-wrapper">
                      <label>مبلغ تراکنش</label>
                      <div class="${paymentResult.status == 'Canceled'
      ? 'canceled-text'
      : 'successful-text'}">
                          <span>${paymentResult.payment?.amount.toString()}</span> <span>ریال</span>
                      </div>
                  </div>
                  <div class="field-wrapper">
                      <label>تاریخ و زمان تراکنش</label>
                      <span>${paymentResult.payment?.resultPaymentDateTime
      .toString()}</span>
                  </div>
                  ${paymentResult.payment?.message != null ? '''
                  <div class="${paymentResult.status == 'Canceled'
      ? 'canceled-text'
      : 'successful-text'}">
                      <span>${paymentResult.payment?.message}</span>
                  </div>
                  ''' : ''}
              </div>
              <div id="footer-payment">
                  <a class="redirect-button" href="${paymentResult.payment
      ?.callbackUrl ?? 'default-link'}">بازگشت به برنامه امداد خودرو</a>
              </div>
          </div>
          <style>
            .payment-details {
                height: 100%;
                width: 100%;
                background: #aaa;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            #resultFrame {
                width: 100%;
                max-width: 23rem;
                text-align.canceled center;
                border: 1px solid #aaaa;
                font-family: "IRANSans(FaNum)";
            }
            #header-payment {
                padding: 1rem;
                font-weight: 600;
                text-align: center;
                background: #f1f2f4;
                font-size: 1.3rem;
                color: #343434;
                border: 1px solid #ddd;
                border-radius: 1rem;
                box-shadow: 0 0 5px 2px #999;
            }
            .body-payment {
                background: #fff;
                border: 1px solid #aaa;
                border-radius: 1rem;
                margin: .5rem 0;
                padding: 1rem;
                box-shadow: 0 0 5px 2px #999;
            }
            #header-payment.successful {
                background-color: #28a745;
                color: #ffffff;
                border-color: #28a745;
            }
            #header-payment.canceled {
                background-color: #dc3545;
                color: #ffffff;
                border-color: #dc3545;
            }
            .redirect-button {
                display: block;
                background-color: #f1f2f4;
                color: #F27128;
                font-weight: 600;
                text-decoration: none;
                border-radius: 1rem;
                padding: 1rem;
                width: 100%;
                margin: auto;
                font-size: 1rem;
                text-align: center;
            }
            .field-wrapper {
                margin-bottom: 1rem;
                color: #343434;
                display: flex;
                flex-direction: row;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px solid #ddd;
                padding-bottom: 1rem;
            }
            .field-wrapper span, .field-wrapper label {
                font-weight: 600;
                color: #888;
                font-size: 1rem;
            }
            .successful-text > span {
                color: #28a745;
                font-size: 1rem;
                text-align: center;
            }
            .canceled-text > span {
                color: #dc3545;
                font-size: 1rem;
                text-align: center;
            }
        </style>
      </div>
  </body>
  </html>
  ''';
}

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

  final String? firstName = body['firstName'];
  final String? lastName = body['lastName'];
  final String? plateNumber = body['plateNumber'];
  final String? licenseNumber = body['licenseNumber'];
  final String? userId = body['userId'];
  final String? serviceId = body['serviceId'];
  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];

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

  if (nationalCode == null) {
    final najiResponse =
    NajiResponse(resultCode: 1, failures: ['کدملی یافت نشد.'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }

  if (mobileNumber == null) {
    final najiResponse = NajiResponse(
        resultCode: 1, failures: ['شماره موبایل یافت نشد.'], data: {});
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
  final localInvoiceId = DateTime
      .now()
      .microsecondsSinceEpoch;
  final tokenTime = DateTime.now();
  final Map<String, dynamic> requestJson;
  final int status;
  final String message;
  final callBackUrl =
      "${Constants.publicUrl}:${Constants
      .port}/callback?localInvoiceId=$localInvoiceId";
  try {
    requestJson = {
      'merchantConfigurationId': Constants.merchantConfigurationId,
      'serviceTypeId': 1,
      'localInvoiceId': localInvoiceId,
      'amountInRials': amount,
      'localDate': localDate.data.toString(),
      'additionalData': '',
      "callbackURL": callBackUrl,
      "paymentId": "0"
    };
    final response = await IpgNetworkModule.instance.dio
        .post('/v1/Token', data: requestJson);
    if (response.statusCode.toString()[0] != '2') {
      return Response.ok(
          NajiResponse(resultCode: 1, failures: [
            'سرویس آسان پرداخت در دسترس نیست، پس از مدتی دوباره تلاش کنید'
          ], data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
    status = response.statusCode ?? -1;
    message = response.statusMessage ?? '';
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
    mobileNumber: mobileNumber,
    nationalCode: nationalCode,
    name: '$firstName $lastName',
    requestpay_datetime: tokenTime,
    requestpay_req_json: jsonEncode(requestJson),
    requestpay_res_json: jsonEncode(refId),
    requestpay_status: status,
    requestpay_msg: message,
    requestpay_result: status == 200 ? 1 : 0,
    callbackUrl: callBackUrl,
  ));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    'refId': refId,
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
          <input type="hidden" name="mobileap" value="$mobileNumber" />
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
    print('Entered Try ');
    final resultpay_datetime = DateTime.now();
    final tranResult = await IpgNetworkModule.instance.dio
        .get('/v1/TranResult', queryParameters: {
      'merchantConfigurationId': Constants.merchantConfigurationId,
      'localInvoiceId': int.parse(localInvoiceId ?? ''),
    });

    InvoiceRepository.instance?.update(
      tranResult.data['refID'],
      InvoiceData(
        rrn: tranResult.data['rrn'],
        payGateTranID: tranResult.data['payGateTranID'],
        amount: tranResult.data['amount'],
        cardNumber: tranResult.data['cardNumber'],
        payGateTranDate: tranResult.data['payGateTranDate'],
        resultpay_datetime: resultpay_datetime,
        resultpay_res_json: jsonEncode(tranResult.data),
        resultpay_msg: tranResult.statusMessage,
        resultpay_result: tranResult.statusCode == 200 ? 1 : 0,
        payment_result: tranResult.statusCode == 200 ? 1 : 0,
        resultpay_status: tranResult.statusCode,
      ),
    );
    print('Updated DB ');

    if (tranResult.statusCode == 472) {
      print('tranresult 472 ');
      return Response.ok(failureHtml, headers: {
        HttpHeaders.contentTypeHeader: 'text/html',
      });
    }

    if (tranResult.statusCode == 200) {
      print('tranresult 200 ');
      //success
      final invoice =
      await InvoiceRepository.instance?.getById(localInvoiceId ?? '-1');

      if (invoice == null) {
        print('invoice null ');
        return Response.ok(
            NajiResponse(
                resultCode: 1,
                failures: ['خطای پایگاه داده'],
                data: {}).getJson(),
            headers: {"Content-Type": "application/json"});
      }

      final najiStatus = await doNajiRequest(invoice);
      if (najiStatus != 0) {
        print('Naji not 0 status');

        ///-1 also comes here, which means HTTP result to naji services was NOT 200!
        //TODO: reverse, cancel
        //TODO: html failure
        final reverseDateTime = DateTime.now();
        final reverseRequestJson = {
          'merchantConfigurationId': Constants.merchantConfigurationId,
          'payGateTranId': int.parse(tranResult.data['payGateTranID']),
        };
        final reverseResult = await IpgNetworkModule.instance.dio
            .post('/v1/Reverse', data: reverseRequestJson);
        InvoiceRepository.instance?.updateReverseData(
            invoice.refId ?? '-1',
            InvoiceData(
              reverse_datetime: reverseDateTime,
              reverse_req_json: jsonEncode(reverseRequestJson),
              reverse_res_json: reverseResult.data,
              reverse_status: reverseResult.statusCode,
              reverse_result: reverseResult.statusCode == 200 ? 1 : 0,
              reverse_msg: reverseResult.statusMessage,
            ));
    //     final najiFailureHtml = '''
    //   <!DOCTYPE html>
    // <html>
    //   <head>
    //     <title>نتیجه تراکنش</title>
    //     <style>
    //       body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
    //       .container { display: flex; flex-direction: column; justify-content: center; align-items: center; }
    //       .button { margin-top: 50px; padding: 10px 20px; font-size: 18px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }
    //     </style>
    //   </head>
    //   <body>
    //       <h1>عملیات ناموفق سرویس دهنده</h1>
    //       <p>سرویس موردنظر انجام نشد. درصورت پرداخت، مبلغ کسر شده حداکثر تا 72 ساعت به حساب شما باز می گردد.</p>
    //        <a href="eks://emdad.behpardaz.net/payment-result?refId=${invoice
    //         .refId}" class="button">بازگشت به برنامه</a>
    //   </body>
    // </html>
    // ''';
        return Response.ok(generatePaymentHtml(PaymentResult(
            status: invoice.verify_result==1? 'Successful':'Canceled',
            statusTitle: 'عملیات ناموفق سرویس دهنده',
            payment: Payment(
              amount: int.parse(invoice.amount ?? '0'),
              resultPaymentDateTime:
              invoice.resultpay_datetime.toString() ?? '',
              message: 'سرویس موردنظر انجام نشد. درصورت پرداخت، مبلغ کسر شده حداکثر تا 72 ساعت به حساب شما باز می گردد.',
              callbackUrl:
              'eks://emdad.behpardaz.net/payment-result?refId=${invoice.refId}',
            ))), headers: {
          HttpHeaders.contentTypeHeader: 'text/html',
        });
      } else {
        print('Naji 0 status ');
        final verifyTime = DateTime.now();
        final verifyRequestJson = {
          'merchantConfigurationId': Constants.merchantConfigurationId,
          'payGateTranId': int.parse(tranResult.data['payGateTranID']),
        };
        final verifyResult = await IpgNetworkModule.instance.dio
            .post('/v1/Verify', data: verifyRequestJson);

        InvoiceRepository.instance?.updateVerifyData(
            invoice.refId ?? '-1',
            InvoiceData(
              verify_datetime: verifyTime,
              verify_req_json: jsonEncode(verifyRequestJson),
              verify_res_json: verifyResult.data,
              verify_status: verifyResult.statusCode,
              verify_result: verifyResult.statusCode == 200 ? 1 : 0,
              verify_msg: verifyResult.statusMessage,
            ));

        final settleTime = DateTime.now();
        final settleRequestJson = {
          'merchantConfigurationId': Constants.merchantConfigurationId,
          'payGateTranId': int.parse(tranResult.data['payGateTranID']),
        };

        print('verify code: ${verifyResult.statusCode} ');
        final settlementResult = await IpgNetworkModule.instance.dio
            .post('/v1/Settlement', data: settleRequestJson);
        InvoiceRepository.instance?.updateSettleData(
            invoice.refId ?? '-1',
            InvoiceData(
              settle_datetime: settleTime,
              settle_req_json: jsonEncode(settleRequestJson),
              settle_res_json: settlementResult.data,
              settle_status: settlementResult.statusCode,
              settle_result: settlementResult.statusCode == 200 ? 1 : 0,
              settle_msg: settlementResult.statusMessage,
            ));
        print('settlement code: ${verifyResult.statusCode} ');


        //     final successHtml = '''
        // <!DOCTYPE html>
        // <html>
        //   <head>
        //     <title>نتیجه تراکنش</title>
        //     <style>
        //       body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        //       .container { display: flex; flex-direction: column; justify-content: center; align-items: center; }
        //       .button { margin-top: 50px; padding: 10px 20px; font-size: 18px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }
        //     </style>
        //   </head>
        //   <body>
        //     <div class="container">
        //       <h1>عملیات موفق</h1>
        //       <p>تراکنش با موفقیت انجام شد</p>
        //       <a href="eks://emdad.behpardaz.net/payment-result?refId=${invoice.refId}" class="button">بازگشت به برنامه</a>
        //     </div>
        //   </body>
        // </html>
        // ''';
        return Response.ok( generatePaymentHtml( PaymentResult(
            status: invoice.payment_result==1? 'Successful':'Cancelled',
            statusTitle: invoice.payment_result==1? 'تراکنش موفق':'تراکنش ناموفق',
            payment: Payment(
              amount: int.parse(invoice.amount ?? '0'),
              resultPaymentDateTime:
              invoice.resultpay_datetime.toString() ?? '',
              message: invoice.payment_result==1? 'پرداخت موفق':'پرداخت ناموفق',
              callbackUrl:
              'eks://emdad.behpardaz.net/payment-result?refId=${invoice.refId}',
            ))), headers: {
          HttpHeaders.contentTypeHeader: 'text/html',
        });
      }
    } else {
      //TODO: modify error, maybe we should read from db to fill fields heere.
      return Response.ok( generatePaymentHtml( PaymentResult(
          status:'Cancelled',
          statusTitle: 'تراکنش ناموفق',
          payment: Payment(
            amount: 0,
            resultPaymentDateTime: '',
            message:'پرداخت ناموفق',
            callbackUrl: '',
          ))), headers: {
        HttpHeaders.contentTypeHeader: 'text/html',
      });
    }
  } catch (e) {
    print(e);
    //TODO: modify error, maybe we should read from db to fill fields heere.
    return Response.ok( generatePaymentHtml( PaymentResult(
        status:'Cancelled',
        statusTitle: 'تراکنش ناموفق',
        payment: Payment(
          amount: 0,
          resultPaymentDateTime: '',
          message:'پرداخت ناموفق',
          callbackUrl: '',
        ))), headers: {
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
        NajiResponse(resultCode: 1, failures: [
          'پرداخت ناموفق، لطفا دوباره تلاش کنید. درصورت کسر مبلغ طی حداکثر 24 ساعت به حساب شما بازمیگردد'
        ], data: {}).getJson(),
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

  if (invoice.najiResult == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['فاکتور موردنظر یافت نشد'],
            data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  if (!Constants.noPayment) {
    final decodedNajiResult = jsonDecode(invoice.najiResult ?? '');
    if (decodedNajiResult['resultStatus'].toString() != '0') {
      return Response.ok(
          NajiResponse(
              resultCode: 1,
              failures: [decodedNajiResult['resultStatusMessage']],
              data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
  }

  final json = jsonDecode(invoice.najiResult!);
  if (json == null || json == {}) {
    if (Constants.noPayment) {
      final najiStatus = await doNajiRequest(invoice);
      final readInvoice =
      await InvoiceRepository.instance?.getByRefId(invoice.refId ?? '');
      final testingJson = jsonDecode(readInvoice!.najiResult!);
      if (testingJson['resultStatus'] != 0) {
        return Response.ok(
            NajiResponse(resultCode: 1, failures: [
              testingJson['resultStatusMessage'] ??
                  'پاسخ مناسب از سرویس ناجی دریافت نشد.'
            ], data: {}).getJson(),
            headers: {"Content-Type": "application/json"});
      }

      return Response.ok(
          NajiResponse(resultCode: 0, failures: [], data: {
            'negativePoint': invoice.serviceId == '1'
                ? NegativePointMapper()
                .map(NajiNegativePointModel.fromJson(testingJson))
                : {},
            'licensePlates': invoice.serviceId == '2'
                ? LicensePlatesMapper().mapList(
                (jsonDecode(testingJson['result']) as List<dynamic>)
                    .map(
                      (e) => NajiLicensesPlateModel.fromJson(e),
                )
                    .toList())
                : {},
            'drivingLicences': invoice.serviceId == '3'
                ? DrivingLicenseMapper().mapList(
                (jsonDecode(testingJson['result']) as List<dynamic>)
                    .map(
                      (e) => NajiDrivingLicensesModel.fromJson(e),
                )
                    .toList())
                : {},
            'vehiclesViolations': invoice.serviceId == '4'
                ? {
              'violations': VehicleViolationsMapper().mapList(
                  (jsonDecode(testingJson['result'])['violations']
                  as List<dynamic>)
                      .map(
                        (e) => ViolationModel.fromJson(e),
                  )
                      .toList()),
              'updateViolationsDate': RowOfData(
                title: 'تاریخ استعلام خلافی',
                svg: '$url/svg/calendar_month.svg',
                description: jsonDecode(
                    testingJson['result'])['updateViolationsDate'],
              ).toJson(),
              'plateChar': RowOfData(
                title: 'پلاک',
                svg: '$url/svg/directions_car.svg',
                description:
                jsonDecode(testingJson['result'])['plateChar'],
              ).toJson(),
              'inquirePrice': RowOfData(
                title: 'جمع کل خلافی',
                svg: '$url/svg/payments.svg',
                description:
                jsonDecode(testingJson['result'])['inquirePrice'],
              ).toJson(),
            }
                : {},
            'violationsAggregate': invoice.serviceId == '5'
                ? ViolationsAggregateMapper().map(
                NajiVehiclesViolationsAggregateModel.fromJson(testingJson))
                : {},
            'vehiclesDocumentsStatus': invoice.serviceId == '6'
                ? VehicleDocumentStatusMapper()
                .map(NajiVehiclesDocumentsStatusModel.fromJson(testingJson))
                : {},
          }).getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      return Response.ok(
          NajiResponse(resultCode: 1, failures: [
            'تراکنش انجام نشد. درصورت پرداخت، مبلغ کسر شده حداکثر تا 72 ساعت به حساب شما باز می گردد.'
          ], data: {}).getJson(),
          headers: {"Content-Type": "application/json"});
    }
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
          'negativePoint': invoice.serviceId == '1'
              ? NegativePointMapper().map(NajiNegativePointModel.fromJson(json))
              : {},
          'licensePlates': invoice.serviceId == '2'
              ? LicensePlatesMapper()
              .mapList((jsonDecode(json['result']) as List<dynamic>)
              .map(
                (e) => NajiLicensesPlateModel.fromJson(e),
          )
              .toList())
              : {},
          'drivingLicences': invoice.serviceId == '3'
              ? DrivingLicenseMapper()
              .mapList((jsonDecode(json['result']) as List<dynamic>)
              .map(
                (e) => NajiDrivingLicensesModel.fromJson(e),
          )
              .toList())
              : {},
          'vehiclesViolations': invoice.serviceId == '4'
              ? {
            'violations': VehicleViolationsMapper().mapList(
                (jsonDecode(json['result']['violations'])
                as List<dynamic>)
                    .map(
                      (e) => ViolationModel.fromJson(e),
                )
                    .toList()),
            'updateViolationsDate': RowOfData(
              title: 'تاریخ استعلام خلافی',
              svg: '$url/svg/calendar_month.svg',
              description: json['result']['updateViolationsDate'],
            ).toJson(),
            'plateChar': RowOfData(
              title: 'پلاک',
              svg: '$url/svg/directions_car.svg',
              description: json['result']['plateChar'],
            ).toJson(),
            'inquirePrice': RowOfData(
              title: 'جمع کل خلافی',
              svg: '$url/svg/payments.svg',
              description: json['result']['inquirePrice'],
            ).toJson(),
          }
              : {},
          'violationsAggregate': invoice.serviceId == '5'
              ? ViolationsAggregateMapper().map(
              NajiVehiclesViolationsAggregateModel.fromJson(json))
              : {},
          'vehiclesDocumentsStatus': invoice.serviceId == '6'
              ? VehicleDocumentStatusMapper()
              .map(NajiVehiclesDocumentsStatusModel.fromJson(json))
              : {},
        }).getJson(),
        headers: {"Content-Type": "application/json"});
  }
}

Future<Response> serviceHistory(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body;
  try {
    body = jsonDecode(bodyString);
  } catch (e) {
    print(e);
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['خطای مقادیر ورودی: شناسه کاربر'],
            data: {}).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final String? guid = body['guid'];
  if (guid == null) {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['کاربر یافت نشد'], data: {})
            .getJson(),
        headers: {"Content-Type": "application/json"});
  }
  final invoiceList = await InvoiceRepository.instance?.getAllForUser(guid);
  if (invoiceList?.isEmpty ?? true) {
    return Response.ok(
        NajiResponse(resultCode: 0, failures: [], data: {[]})
            .getJson(),
        headers: {"Content-Type": "application/json"});
  }

  return Response.ok(
      NajiResponse(
          resultCode: 0, failures: [], data: invoiceList?.map((invoice) {
        String timePart = invoice.localDate?.split(' ')[1] ?? '';
        final jalaliDate = gregorianToJalali(
          int.parse(invoice.localDate?.substring(0, 4) ?? '0'),
          int.parse(invoice.localDate?.substring(5, 7) ?? '0'),
          int.parse(invoice.localDate?.substring(8, 10) ?? '0'),
        ).join('/');
        print(invoice.localDate?.substring(0, 4));
        print(invoice.localDate?.substring(5, 7));
        print(invoice.localDate?.substring(8, 10));
        print(jalaliDate);
        return {
          'localInvoiceId': invoice.localInvoiceId ?? '',
          'serviceName': invoice.serviceName ?? '',
          'rrn': invoice.rrn ?? '',
          'date': jalaliDate,
          'time': timePart.substring(0,8),
          'refId':invoice.refId,
          'hasNajiResult': (invoice.najiResult?.isNotEmpty ?? false),
        };
      }).toList()).getJson(),
      headers: {"Content-Type": "application/json"});
}
