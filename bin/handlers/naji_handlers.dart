import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import '../naji_response.dart';
import '../clients/naji_client.dart';
import '../db/user_repository.dart';
import '../models/user_model.dart';

Future<Response> validateUser(Request request) async {
  final String? nationalCode;
  final String? mobileNumber;
  final String? guid;
  final String? firstName;
  final String? lastName;
  try {
    final bodyString = await request.readAsString();
    final Map<String, dynamic> body = jsonDecode(bodyString);
    nationalCode = body['nationalCode'];
    mobileNumber = body['mobileNumber'];
    guid = body['guid'];
    firstName = body['firstName'];
    lastName = body['lastName'];
    if (mobileNumberError(mobileNumber) == null &&
        nationalCodeError(nationalCode) == null) {
      final response = await NajiNetworkModule.instance.dio
          .post('/naji/validityUser', data: {
        'nationalCode': nationalCode,
        'mobileNo': mobileNumber,
      });
      if (response.data['resultStatus'] == 0) {
        final najiResponse = NajiResponse(resultCode: 0, failures: [], data: {
          'message': response.data['resultStatusMessage'],
          "isRegistered": true,
        });
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
  } catch (e) {
    final najiResponse = NajiResponse(
        resultCode: 1, failures: ['خطا در دریافت اطلاعات'], data: {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }
}

Future<Response> sendOtp(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  final String? nationalCode = body['nationalCode'];
  final String? mobileNumber = body['mobileNumber'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null) {
    final response = await NajiNetworkModule.instance.dio
        .post('/naji/initialRegister', data: {
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
  // final String? guid = body['guid'];
  // final String? firstName = body['firstName'];
  // final String? lastName = body['lastName'];

  if (mobileNumberError(mobileNumber) == null &&
      nationalCodeError(nationalCode) == null &&
      otpError(otp) == null) {
    final response =
        await NajiNetworkModule.instance.dio.post('/naji/registerUser', data: {
      'nationalCode': nationalCode,
      'mobileNo': mobileNumber,
      'otp': otp,
    });
    if (response.data['resultStatus'] == 0) {
      // await UserRepository.instance?.saveUserInDb(
      //   UserModel(
      //     guid: guid,
      //     firstName: firstName,
      //     lastName: lastName,
      //     mobileNumber: mobileNumber,
      //     nationalCode: nationalCode,
      //   ),
      // );
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

Future<Map<String, dynamic>?> drivingLicences(
    {required String nationalCode, required String mobileNumber}) async {
  final response =
      await NajiNetworkModule.instance.dio.post('/naji/drivingLicenses', data: {
    'nationalCode': nationalCode,
    'mobileNo': mobileNumber,
  });

  if (response.statusCode == 200) {
    return response.data;
  }
  return null;
}

Future<Map<String, dynamic>?> negativePoint(
    {required String nationalCode,
    required String mobileNumber,
    required String licenseNumber}) async {
  final response =
      await NajiNetworkModule.instance.dio.post('/naji/negativePoint', data: {
    'nationalCode': nationalCode,
    'mobileNo': mobileNumber,
    'licenseNumber': licenseNumber,
  });

  if (response.statusCode == 200) {
    return response.data;
  }
  return null;
}

Future<Map<String, dynamic>?> licensePlates(
    {required String nationalCode, required String mobileNumber}) async {
  final response =
      await NajiNetworkModule.instance.dio.post('/naji/licensePlates', data: {
    'nationalCode': nationalCode,
    'mobileNo': mobileNumber,
  });

  if (response.statusCode == 200) {
    return response.data;
  }
  return null;
}

Future<Map<String, dynamic>?> vehiclesViolations(
    {required String plateNumber,
    required String nationalCode,
    required String mobileNumber}) async {
  final response = await NajiNetworkModule.instance.dio
      .post('/naji/vehiclesViolations', data: {
    'nationalCode': nationalCode,
    'mobileNo': mobileNumber,
    'plateNo': plateNumber,
  });

  if (response.statusCode == 200) {
    return response.data;
  }
  return null;
}

Future<Map<String, dynamic>?> violationsAggregate(
    {required String nationalCode,
    required String mobileNumber,
    required String plateNumber}) async {
  final response = await NajiNetworkModule.instance.dio
      .post('/naji/violationsAggregate', data: {
    'nationalCode': nationalCode,
    'mobileNo': mobileNumber,
    'plateNo': plateNumber,
  });

  if (response.statusCode == 200) {
    return response.data;
  }
  return null;
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
        await NajiNetworkModule.instance.dio.get('/naji/violationsImage')
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

Future<Map<String, dynamic>?> vehiclesDocumentsStatus(
    {required String nationalCode,
    required String mobileNumber,
    required String plateNumber}) async {
  final response = await NajiNetworkModule.instance.dio
      .post('/naji/vehiclesDocumentsStatus', data: {
    'nationalCode': nationalCode,
    'mobileNo': mobileNumber,
    'plateNo': plateNumber,
  });

  if (response.statusCode == 200) {
    return response.data;
  }
  return null;
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
