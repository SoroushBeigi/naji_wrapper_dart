import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'naji_response.dart';
import 'client.dart';

Response echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Response getAllServices(Request request) {

  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: [
    {
      'serviceName': 'نمره منفی',
      "price": 50000,
      'inputs': ['nationalCode', 'mobileNumber', 'licenseNumber'],
      'title': 'negativePoint'
    },
    {
      'serviceName': 'پلاک‌های فعال',
      "price": 50000,
      'inputs': ['nationalCode', 'mobileNumber'],
      'title': 'licensePlates'
    },
    {
      'serviceName': 'استعلام گواهینامه',
      "price": 50000,
      'inputs': ['nationalCode', 'mobileNumber'],
      'title': 'drivingLicences'
    },
    {
      'serviceName': 'استعلام خلافی',
      "price": 50000,
      'inputs': ['nationalCode', 'mobileNumber', 'plateNumber'],
      'title': 'vehiclesViolations'
    },
    {
      'serviceName': 'تجمیع تخلفات خودرو',
      "price": 50000,
      'inputs': ['nationalCode', 'mobileNumber', 'plateNumber'],
      'title': 'violationsAggregate'
    },
    {
      'serviceName': 'کارت و سند',
      "price": 50000,
      'inputs': ['nationalCode', 'mobileNumber', 'plateNumber'],
      'title': 'vehiclesDocumentsStatus'
    }
  ]);
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> validateUser(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null) {
    final response =
        await NetworkModule.instance.dio.post('/naji/validityUser', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
    });
    if (response.data['resultStatus'] == 0) {
      final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
        'message':
            "کاربر قبلا ثبت نام کرده است. نیازی به ثبت نام مجدد وجود ندارد",
        "isRegistered": true,
      });
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
        //TODO: set to 1
          resultCode: 0,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        Response(520);
  }
}

Future<Response> sendOtp(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null) {
    final response =
        await NetworkModule.instance.dio.post('/naji/initialRegister', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
    });
    if (response.data['resultStatus'] == 0) {
      final najiResponse = NajiResponse(
          resultCode: 0,
          failures: [],
          data: {'message': response.data['resultStatusMessage']});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        Response(520);
  }
}

Future<Response> verifyOtp(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? otp = body['otp'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      otpError(otp) == null) {
    final response =
        await NetworkModule.instance.dio.post('/naji/registerUser', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
      'otp': otp,
    });
    if (response.data['resultStatus'] == 0) {
      final najiResponse = NajiResponse(
          resultCode: 0,
          failures: [],
          data: {'message': response.data['resultStatusMessage']});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        otpError(otp) ??
        Response(520);
  }
}

Future<Response> drivingLicences(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null) {
    final response =
        await NetworkModule.instance.dio.post('/naji/drivingLicenses', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
    });

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        Response(520);
  }
}

Future<Response> negativePoint(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? licenseNumber = body['licenseNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      licenseNumberError(licenseNumber) == null) {
    final response =
        await NetworkModule.instance.dio.post('/naji/negativePoint', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
      'licenseNumber': licenseNumber,
    });

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        licenseNumberError(licenseNumber) ??
        Response(520);
  }
}

Future<Response> licensePlates(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null) {
    final response =
        await NetworkModule.instance.dio.post('/naji/licensePlates', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
    });

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: response.data['resultStatusMessage'],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        Response(520);
  }
}

Future<Response> vehiclesViolations(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? plateNumber = body['plateNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      plateNumberError(plateNumber) == null) {
    final response = await NetworkModule.instance.dio
        .post('/naji/vehiclesViolations', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
      'plateNo': plateNumber,
    });

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        plateNumberError(plateNumber) ??
        Response(520);
  }
}

Future<Response> violationsAggregate(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? plateNumber = body['plateNumber'];
  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      plateNumberError(plateNumber) == null) {
    final response = await NetworkModule.instance.dio
        .post('/naji/violationsAggregate', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
      'plateNo': plateNumber,
    });

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        plateNumberError(plateNumber) ??
        Response(520);
  }
}

Future<Response> violationsImage(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? plateNumber = body['plateNumber'];
  final String? violationId = body['violationId'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      plateNumberError(plateNumber) == null &&
      violationIdError(violationId) == null) {
    final response =
        await NetworkModule.instance.dio.get('/naji/violationsImage')
          ..headers.add('nationalCode', nationalCode ?? '')
          ..headers.add('mobileNo', mobileNumber ?? '')
          ..headers.add('plateNo', plateNumber ?? '')
          ..headers.add('violationId', violationId ?? '');

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        plateNumberError(plateNumber) ??
        violationIdError(violationId) ??
        Response(520);
  }
}

Future<Response> vehiclesDocumentsStatus(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];
  final String? plateNumber = body['plateNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      plateNumberError(plateNumber) == null) {
    final response = await NetworkModule.instance.dio
        .post('/naji/vehiclesDocumentsStatus', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
      'plateNo': plateNumber,
    });

    if (response.data['resultStatus'] == 0) {
      final najiResponse =
          NajiResponse(resultCode: 0, failures: [], data: response.data);
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    } else {
      final najiResponse = NajiResponse(
          resultCode: 1,
          failures: [response.data['resultStatusMessage']],
          data: {});
      return Response.ok(najiResponse.getJson(),
          headers: {"Content-Type": "application/json"});
    }
  } else {
    return mobileNumberError(mobileNumber) ??
        nationalCodeError(nationalCode) ??
        plateNumberError(plateNumber) ??
        Response(520);
  }
}

Response? nationalCodeError(String? nationalCode) {
  if (nationalCode == null || nationalCode == '') {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['کدملی نمیتواند خالی باشد'])
            .getJson(),
        headers: {"Content-Type": "application/json"});
  } else if (nationalCode.length != 10) {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['کدملی باید 10 کاراکتر باشد'])
            .getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? mobileNumberError(String? mobileNumber) {
  if (mobileNumber == null || mobileNumber == '') {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['شماره تلفن نمیتواند خالی باشد'])
            .getJson(),
        headers: {"Content-Type": "application/json"});
  } else if (mobileNumber.length != 11) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['شماره تلفن باید 11 کاراکتر باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? otpError(String? otp) {
  if (otp == null || otp == '') {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['کد ارسالی نمیتواند خالی باشد'])
            .getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? licenseNumberError(String? licenseNumber) {
  if (licenseNumber == null || licenseNumber == '') {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            failures: ['شماره سریال گواهینامه نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? plateNumberError(String? plateNumber) {
  if (plateNumber == null || plateNumber == '') {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['شماره پلاک نمیتواند خالی باشد'])
            .getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}

Response? violationIdError(String? violationId) {
  if (violationId == null || violationId == '') {
    return Response.ok(
        NajiResponse(resultCode: 1, failures: ['شناسه تخلف نمیتواند خالی باشد'])
            .getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return null;
}
