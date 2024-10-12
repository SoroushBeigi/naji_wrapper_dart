import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import '../naji_response.dart';
import '../db/service_repository.dart';
import '../models/service_model.dart';

Future<Response> getService(Request request) async {
  if (request.url.pathSegments.length == 2 && request.url.pathSegments[0] == 'service') {
    final  id = request.url.pathSegments[1];
    final dbResult = await ServiceRepository.instance!.getById(id);
    final najiResponse = NajiResponse(
        resultCode: 0,
        failures: [],
        data: dbResult?.toJson() ?? {});
    return Response.ok(najiResponse.getJson(),
        headers: {"Content-Type": "application/json"});
  }
  return Response.notFound('Not found');
}

Future<Response> getAllServices(Request request) async {
  final dbResult = await ServiceRepository.instance!.getAll();
  final najiResponse = NajiResponse(
      resultCode: 0,
      failures: [],
      data: dbResult.map((e) => e.toJson()).toList());
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> addService(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  if (body['price'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['قیمت نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  if (body['title'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['عنوان نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  if (body['serviceName'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['نام سرویس  نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  if (body['inputs'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['ورودی ها نمیتوانند خالی باشند']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final dbResult = await ServiceRepository.instance!.write(ServiceModel(
      price: body['price'],
      serviceName: body['serviceName'],
      title: body['title'],
      inputs: body['inputs']));

  final najiResponse = NajiResponse(
    resultCode: 0,
    failures: [],
    data: {'message': 'با موفقیت اضافه شد'},
  );
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> updateService(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);

  if (body['id'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['شناسه نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  if (body['price'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['قیمت نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  if (body['title'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['عنوان نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  if (body['serviceName'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['نام سرویس  نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  if (body['inputs'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['ورودی ها نمیتوانند خالی باشند']).getJson(),
        headers: {"Content-Type": "application/json"});
  }

  final dbResult = await ServiceRepository.instance!.update(
    body['id'],
    ServiceModel(
      price: body['price'],
      serviceName: body['serviceName'],
      title: body['title'],
      inputs: body['inputs'],
    ),
  );

  final najiResponse = NajiResponse(
    resultCode: 0,
    failures: [],
    data: {'message': 'با موفقیت بروزرسانی شد'},
  );
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}

Future<Response> deleteService(Request request) async {
  final bodyString = await request.readAsString();
  final Map<String, dynamic> body = jsonDecode(bodyString);
  if (body['id'] == null) {
    return Response.ok(
        NajiResponse(
            resultCode: 1,
            data: {},
            failures: ['شناسه نمیتواند خالی باشد']).getJson(),
        headers: {"Content-Type": "application/json"});
  }
  final dbResult = await ServiceRepository.instance!.delete(body['id']);

  final najiResponse = NajiResponse(
    resultCode: 0,
    failures: [],
    data: {'message': 'با موفقیت حذف شد'},
  );
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}