import 'package:postgres/postgres.dart';

import '../models/invoice_model.dart';
import 'db_mixins.dart';
import '../utils/datetime_to_timestamp.dart';

class InvoiceRepository
    with
        Readable<InvoiceData>,
        Writable<InvoiceData>,
        Deletable,
        Updatable<InvoiceData> {
  static InvoiceRepository? instance;

  InvoiceRepository._internal(this.connection);

  factory InvoiceRepository(Connection connection) {
    return instance ??= InvoiceRepository._internal(connection);
  }

  void init() {
    instance = InvoiceRepository._internal(connection);
  }

  final Connection connection;

  @override
  Future<void> write(invoiceData) async {
    // String keys = '';
    // String values = '';
    // invoiceData.getFields().forEach((key, value) {
    //   keys += "$key, ";
    //   values += "'$value', ";
    // });
    // String query = 'INSERT INTO invoices (';
    final result = await connection.execute(
      Sql.named(
          'INSERT INTO invoices (redirect_url, request_referenceid, order_type, tag2, tag1, paymenter_email, order_desc, order_datetime , paymenter_mobile, paymenter_natcode, paymenter_name, requestpay_datetime, requestpay_req_json, requestpay_res_json, requestpay_status, requestpay_msg, requestpay_result) VALUES (@callbackUrl, @refId, @serviceId, @plateNumber, @licenseNumber, @userId, @localInvoiceId, @localDate, @mobileNumber, @nationalCode, @name, @requestpay_datetime, @requestpay_req_json, @requestpay_res_json, @requestpay_status, @requestpay_msg, @requestpay_result)'),
      parameters: {
        'callbackUrl': invoiceData.callbackUrl,
        'refId': invoiceData.refId,
        'serviceId': invoiceData.serviceId,
        'plateNumber': invoiceData.plateNumber,
        'licenseNumber': invoiceData.licenseNumber,
        'userId': invoiceData.userId,
        'localInvoiceId': invoiceData.localInvoiceId,
        'localDate':
            localDateToTimestamp(invoiceData.localDate ?? '00000000 000000'),
        'mobileNumber': invoiceData.mobileNumber,
        'nationalCode': invoiceData.nationalCode,
        'name': invoiceData.name,
        'requestpay_datetime': dateTimeToTimestamp(
            invoiceData.requestpay_datetime ?? DateTime(2000)),
        'requestpay_req_json': invoiceData.requestpay_req_json,
        'requestpay_res_json': invoiceData.requestpay_res_json,
        'requestpay_status': invoiceData.requestpay_status,
        'requestpay_msg': invoiceData.requestpay_msg,
        'requestpay_result': invoiceData.requestpay_result,
      },
    );
  }

  @override
  Future<List<InvoiceData>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  Future<List<InvoiceData>?> getAllForUser(String guid) async {
    final result = await connection.execute(
        Sql.named(
            "SELECT order_desc, tag3, tracking_code, order_datetime, extra_data, request_referenceid, paymenter_mobile, paymenter_natcode, tag2, tag1, order_type FROM invoices WHERE paymenter_email = @guid"),
        parameters: {'guid': guid});
    if (result.isEmpty) {
      return null;
    }
    return result
        .map(
          (element) => InvoiceData(
            localInvoiceId: element[0].toString(),
            serviceName: element[1].toString(),
            rrn: element[2]?.toString() ,
            localDate: element[3].toString(),
            najiResult: element[4].toString(),
            refId: element[5].toString(),
            mobileNumber: element[6]?.toString(),
            nationalCode: element[7]?.toString(),
            plateNumber: element[8]?.toString(),
            licenseNumber: element[9]?.toString(),
            serviceId: element[10]?.toString(),
          ),
        )
        .toList();
  }

  Future<InvoiceData?> getByRefId(String refId) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM invoices WHERE request_referenceid=@refId"),
      parameters: {'refId': refId},
    );
    if (result.isEmpty) {
      return null;
    }
    return InvoiceData(
      id: int.parse(result[0][0].toString()),
      serviceId: result[0][1].toString(),
      localDate: result[0][2].toString(),
      name: result[0][3].toString(),
      mobileNumber: result[0][4].toString(),
      userId: result[0][5].toString(),
      nationalCode: result[0][6].toString(),
      cardNumber: result[0][8].toString(),
      amount: result[0][10].toString(),
      refId: result[0][11].toString(),
      localInvoiceId: result[0][15].toString(),
      payGateTranID: result[0][17].toString(),
      rrn: result[0][18].toString(),
      payGateTranDate: result[0][25].toString(),
      licenseNumber: result[0][48].toString(),
      plateNumber: result[0][49].toString(),
      serviceName: result[0][50].toString(),
      najiResult: result[0][57].toString(),
    );
  }

  @override
  Future<InvoiceData?> getById(String localInvoiceId) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM invoices WHERE order_desc=@localInvoiceId"),
      parameters: {'localInvoiceId': localInvoiceId},
    );
    if (result.isEmpty) {
      return null;
    }
    return InvoiceData(
      id: int.parse(result[0][0].toString()),
      serviceId: result[0][1].toString(),
      localDate: result[0][2].toString(),
      name: result[0][3].toString(),
      mobileNumber: result[0][4].toString(),
      userId: result[0][5].toString(),
      nationalCode: result[0][6].toString(),
      cardNumber: result[0][8].toString(),
      amount: result[0][10].toString(),
      refId: result[0][11].toString(),
      payment_result: int.tryParse(result[0][13].toString()),
      localInvoiceId: result[0][15].toString(),
      payGateTranID: result[0][17].toString(),
      rrn: result[0][18].toString(),
      payGateTranDate: result[0][25].toString(),
      licenseNumber: result[0][48].toString(),
      plateNumber: result[0][49].toString(),
      serviceName: result[0][50].toString(),
      najiResult: result[0][57].toString(),
    );
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  updateVerifyData(String refId, InvoiceData invoice) async {
    final result = await connection.execute(
      Sql.named(
          "UPDATE invoices SET verify_datetime=@verify_datetime, verify_req_json=@verify_req_json, verify_res_json=@verify_res_json, verify_status=@verify_status, verify_result=@verify_result, verify_msg=@verify_msg WHERE request_referenceid=@refId"),
      parameters: {
        'verify_datetime':
            dateTimeToTimestamp(invoice.verify_datetime ??DateTime(2000)),
        'verify_req_json': invoice.verify_req_json,
        'verify_res_json': invoice.verify_res_json,
        'verify_status': invoice.verify_status,
        'verify_result': invoice.verify_result,
        'verify_msg': invoice.verify_msg,
        'refId': refId,
      },
    );
  }

  updateSettleData(String refId, InvoiceData invoice) async {
    final result = await connection.execute(
      Sql.named(
          "UPDATE invoices SET settle_datetime=@settle_datetime, settle_req_json=@settle_req_json, settle_res_json=@settle_res_json, settle_status=@settle_status, settle_result=@settle_result, settle_msg=@settle_msg WHERE request_referenceid=@refId"),
      parameters: {
        'settle_datetime':
            dateTimeToTimestamp(invoice.settle_datetime ??DateTime(2000)),
        'settle_req_json': invoice.settle_req_json,
        'settle_res_json': invoice.settle_res_json,
        'settle_status': invoice.settle_status,
        'settle_result': invoice.settle_result,
        'settle_msg': invoice.settle_msg,
        'refId': refId,
      },
    );
  }

  updateReverseData(String refId, InvoiceData invoice) async {
    final result = await connection.execute(
      Sql.named(
          "UPDATE invoices SET reverse_datetime=@reverse_datetime, reverse_req_json=@reverse_req_json, reverse_res_json=@reverse_res_json, reverse_status=@reverse_status, reverse_result=@reverse_result, reverse_msg=@reverse_msg WHERE request_referenceid=@refId"),
      parameters: {
        'reverse_datetime':
        dateTimeToTimestamp(invoice.reverse_datetime ?? DateTime(2000)),
        'reverse_req_json': invoice.reverse_req_json,
        'reverse_res_json': invoice.reverse_res_json,
        'reverse_status': invoice.reverse_status,
        'reverse_result': invoice.reverse_result,
        'reverse_msg': invoice.reverse_msg,
        'refId': refId,
      },
    );
  }


  @override
  Future<void> update(String refId, InvoiceData invoice) async {
    if (invoice.najiResult != null) {
      final result = await connection.execute(
        Sql.named(
            "UPDATE invoices SET extra_data=@najiResult WHERE request_referenceid=@refId"),
        parameters: {'najiResult': invoice.najiResult, 'refId': refId},
      );
    } else {
      final result = await connection.execute(
        Sql.named(
            "UPDATE invoices SET tracking_code=@rrn, gateway_code=@payGateTranID, card_holder_pan=@cardNumber, resultpay_datetime=@resultpay_datetime, payment_datetime=@payGateTranDate, resultpay_res_json=@resultpay_res_json,resultpay_msg=@resultpay_msg, resultpay_result=@resultpay_result, resultpay_status=@resultpay_status, payment_result=@payment_result WHERE request_referenceid=@refId"),
        parameters: {
          'rrn': invoice.rrn,
          'payGateTranID': invoice.payGateTranID,
          'cardNumber': invoice.cardNumber,
          'payGateTranDate': ipgTimeToTimestamp(
              invoice.payGateTranDate ?? '0000-00-00T00:00:00.0000000'),
          'resultpay_datetime':
              dateTimeToTimestamp(invoice.resultpay_datetime ?? DateTime(2000)),
          'resultpay_res_json': invoice.resultpay_res_json,
          'resultpay_msg': invoice.resultpay_msg,
          'resultpay_result': invoice.resultpay_result,
          'resultpay_status': invoice.resultpay_status,
          'payment_result':invoice.payment_result,
          'refId': refId
        },
      );
    }
  }
}
