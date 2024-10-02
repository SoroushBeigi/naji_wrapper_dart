import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'naji_response.dart';

Response echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Response getAllServices(Request request) {
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: [
    {'serviceName': 'نمره منفی', "price": 50000},
    {'serviceName': 'پلاک‌های فعال', "price": 50000},
    {'serviceName': 'استعلام گواهینامه', "price": 50000},
    {'serviceName': 'استعلام خلافی', "price": 50000},
    {'serviceName': 'تجمیع تخلفات خودرو', "price": 50000},
    {'serviceName': 'کارت و سند', "price": 50000}
  ]);
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> validateUser(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'] as String?;
  final String? mobileNumber = body['mobileNumber'] as String?;

  if(mobileNumberError(mobileNumber)==null && nationalCodeError(nationalCode)==null){
    //TODO: api call
    Future.delayed(const Duration(seconds: 2));
    final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
      'message': "کاربر قبال ثبت نام کرده است. نیازی به ثبت نام مجدد وجود ندارد"
    });
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }else{
    return mobileNumberError(mobileNumber) ?? nationalCodeError(nationalCode) ?? Response(520);
  }

}

Future<Response> sendOtp(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'] as String?;
  final String? mobileNumber = body['mobileNumber'] as String?;


  if(mobileNumberError(mobileNumber)==null && nationalCodeError(nationalCode)==null){
    //TODO: api call
    Future.delayed(const Duration(seconds: 2));
    final najiResponse = NajiResponse(
        resultCode: 0,
        failures: [],
        data: {'message': "عملیات با موفقیت انجام شد"});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }else{
    return mobileNumberError(mobileNumber) ?? nationalCodeError(nationalCode) ?? Response(520);
  }
}

Future<Response> verifyOtp(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'] as String?;
  final String? mobileNumber = body['mobileNumber'] as String?;
  final String? otp = body['otp'] as String?;

  if(mobileNumberError(mobileNumber)==null && nationalCodeError(nationalCode)==null && otpError(otp)==null){
    //TODO: api call
    Future.delayed(const Duration(seconds: 2));
    final najiResponse = NajiResponse(
        resultCode: 0,
        failures: [],
        data: {'message': "عملیات با موفقیت انجام شد"});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }else{
    return mobileNumberError(mobileNumber) ?? nationalCodeError(nationalCode) ??otpError(otp)?? Response(520);
  }

}

Future<Response> drivingLicences(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'] as String?;
  final String? mobileNumber = body['mobileNumber'] as String?;

  if(mobileNumberError(mobileNumber)==null && nationalCodeError(nationalCode)==null){
    //TODO: api call
    Future.delayed(const Duration(seconds: 2));
    final najiResponse = NajiResponse(resultCode: 0, failures: [], data: [
      {
        "nationalCode": "0150506651",
        "firstName": "محمد سروش",
        "lastName": "معصوم بيكي",
        "title": "پايه سوم",
        "rahvarStatus": "تحويل به پست",
        "barcode": "18593000017055775950",
        "printNumber": "4019483152",
        "printDate": "1402/06/14",
        "validYears": "10"
      }
    ]);
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }else{
    return mobileNumberError(mobileNumber) ?? nationalCodeError(nationalCode) ?? Response(520);
  }

}

Future<Response> negativePoint(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'] as String?;
  final String? mobileNumber = body['mobileNumber'] as String?;
  final String? licenseNumber = body['licenseNumber'] as String?;

  if(mobileNumberError(mobileNumber)==null && nationalCodeError(nationalCode)==null && licenseNumberError(licenseNumber)==null){
    //TODO: api call
    Future.delayed(const Duration(seconds: 2));
    final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
      "isDrivingAllowed": "true",
      "negativePoint": "0",
      "resultStatus": 0,
      "resultStatusMessage": "عملیات با موفقیت انجام شد"
    });
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }else{
    return mobileNumberError(mobileNumber) ?? nationalCodeError(nationalCode) ??licenseNumberError(licenseNumber)?? Response(520);
  }

}

Future<Response> licensePlates(Request request) async {
  final nationalCode = request.context['nationalCode'];
  final mobileNumber = request.context['mobileNumber'];
  //TODO: check inputs
  //TODO: api call
  Future.delayed(const Duration(seconds: 2));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: [
    {
      "serial": null,
      "licensePlateNumber": null,
      "description": null,
      "separationDate": null,
      "licensePlate": "پلاک موجود نمی باشد"
    }
  ]);
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> vehiclesViolations(Request request) async {
  final nationalCode = request.context['nationalCode'];
  final mobileNumber = request.context['mobileNumber'];
  final plateNumber = request.context['plateNumber'];
  //TODO: check inputs
  //TODO: api call
  Future.delayed(const Duration(seconds: 2));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    "items": [
      {
        "violationid": "0",
        "violationoccureddate": "0 - 0",
        "violationoccuredtime": "0",
        "violationdeliverytypename": "0",
        "violationaddress": "0",
        "violationtypeid": "0",
        "violationtypename": "0",
        "finalprice": 0,
        "paperid": "0",
        "paymentid": "0",
        "hasimage": "false",
        "platedictation": "0",
        "plateChar": " شخصي  ايران 59 ــ  376ص13",
        "updateviolationsdate": "0",
        "inquirydate": "0",
        "inquirytime": "0",
        "pricestatus": "0"
      }
    ]
  });
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> violationsAggregate(Request request) async {
  final nationalCode = request.context['nationalCode'];
  final mobileNumber = request.context['mobileNumber'];
  final plateNumber = request.context['plateNumber'];
  //TODO: check inputs
  //TODO: api call
  Future.delayed(const Duration(seconds: 2));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    "paperId": "5055448400198",
    "paymentId": "19700",
    "plateChar": " شخصي  ايران 59 ــ  376ص13",
    "price": "0",
    "priceStatus": "0",
    "resultStatus": 0,
    "resultStatusMessage": "عملیات با موفقیت انجام شد"
  });
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> violationsImage(Request request) async {
  final nationalCode = request.context['nationalCode'];
  final mobileNumber = request.context['mobileNumber'];
  final plateNumber = request.context['plateNumber'];
  final violationId = request.context['violationId'];
  //TODO: check inputs
  //TODO: api call
  Future.delayed(const Duration(seconds: 2));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    "plate": "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",
    "vehicle": "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",
  });
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> vehiclesDocumentsStatus(Request request) async {
  final nationalCode = request.context['nationalCode'];
  final mobileNumber = request.context['mobileNumber'];
  final plateNumber = request.context['plateNumber'];
  //TODO: check inputs
  //TODO: api call
  Future.delayed(const Duration(seconds: 2));
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
    "cardPostalBarcode": "18540004911163920623",
    "cardPrintDate": "1402/02/11",
    "cardStatusTitle": "تحويل شده به پست",
    "documentPrintDate": "1398/09/12",
    "documentStatusTitle": "صدور",
    "plateChar": "ایران ۵۹ - ۳۷۶ ص  ۱۳",
    "resultStatus": 0,
    "resultStatusMessage": "عملیات با موفقیت انجام شد"
  });
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}


Response? nationalCodeError(String? nationalCode) {
  if (nationalCode == null|| nationalCode=='') {
    return Response.ok(
        NajiResponse(resultCode: 1,failures: ['کدملی نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? mobileNumberError(String? mobileNumber) {
  if (mobileNumber == null|| mobileNumber=='') {
    return Response.ok(
        NajiResponse(resultCode: 1,failures: ['شماره تلفن نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? otpError(String? otp) {
  if (otp == null|| otp=='') {
    return Response.ok(
        NajiResponse(resultCode: 1,failures: ['کد ارسالی نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? licenseNumberError(String? licenseNumber) {
  if (licenseNumber == null|| licenseNumber=='') {
    return Response.ok(
        NajiResponse(resultCode: 1,failures: ['شماره سریال گواهینامه نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}


