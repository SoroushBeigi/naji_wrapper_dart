import 'package:postgres/postgres.dart';

import '../models/invoice_model.dart';
import 'db_mixins.dart';

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
          'INSERT INTO invoices (refId, serviceId, plateNumber, licenseNumber, userId, localInvoiceId, localDate) VALUES (@refId, @serviceId, @plateNumber, @licenseNumber, @userId, @localInvoiceId, @localDate)'),
      parameters: {
        'refId': invoiceData.refId,
        'serviceId': invoiceData.serviceId,
        'plateNumber': invoiceData.plateNumber,
        'licenseNumber': invoiceData.licenseNumber,
        'userId': invoiceData.userId,
        'localInvoiceId': invoiceData.localInvoiceId,
        'localDate': invoiceData.localDate,
      },
    );
  }

  @override
  Future<List<InvoiceData>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  Future<InvoiceData?> getByRefId(String refId) async {
    final result = await connection.execute(
      Sql.named(
          "SELECT * FROM invoices WHERE refId=@refId AND isDeleted=false"),
      parameters: {'refId': refId},
    );
    if (result.isEmpty) {
      return null;
    }
    return InvoiceData(
      id: int.parse(result[0][0].toString()),
      refId: result[0][1].toString(),
      nationalCode: result[0][2].toString(),
      serviceId: result[0][3].toString(),
      serviceName: result[0][4].toString(),
      mobileNumber: result[0][5].toString(),
      plateNumber: result[0][6].toString(),
      licenseNumber: result[0][7].toString(),
      userId: result[0][8].toString(),
      localInvoiceId: result[0][12].toString(),
      localDate: result[0][13].toString(),
      rrn: result[0][14].toString(),
      payGateTranID: result[0][15].toString(),
      amount: result[0][16].toString(),
      cardNumber: result[0][17].toString(),
      payGateTranDate: result[0][18].toString(),
      serviceStatusCode: result[0][19].toString(),
      najiResult: result[0][20].toString(),
    );
  }

  @override
  Future<InvoiceData?> getById(String localInvoiceId) async {
    final result = await connection.execute(
      Sql.named(
          "SELECT * FROM invoices WHERE localInvoiceId=@localInvoiceId AND isDeleted=false"),
      parameters: {'localInvoiceId': localInvoiceId},
    );
    if (result.isEmpty) {
      return null;
    }
    return InvoiceData(
      id: int.parse(result[0][0].toString()),
      refId: result[0][1].toString(),
      nationalCode: result[0][2].toString(),
      serviceId: result[0][3].toString(),
      serviceName: result[0][4].toString(),
      mobileNumber: result[0][5].toString(),
      plateNumber: result[0][6].toString(),
      licenseNumber: result[0][7].toString(),
      userId: result[0][8].toString(),
      localInvoiceId: result[0][12].toString(),
      localDate: result[0][13].toString(),
      rrn: result[0][14].toString(),
      payGateTranID: result[0][15].toString(),
      amount: result[0][16].toString(),
      cardNumber: result[0][17].toString(),
      payGateTranDate: result[0][18].toString(),
      serviceStatusCode: result[0][19].toString(),
      najiResult: result[0][20].toString(),
    );
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> update(String refId, InvoiceData model) async {
    if(model.najiResult!=null){
      final result = await connection.execute(
        Sql.named(
            "UPDATE invoices SET najiResult=@najiResult WHERE refId=@refId"),
        parameters: {
          'najiResult': model.najiResult,
          'refId': refId
        },
      );
    }
    final result = await connection.execute(
      Sql.named(
          "UPDATE invoices SET rrn=@rrn, payGateTranID=@payGateTranID, amount=@amount, cardNumber=@cardNumber, payGateTranDate=@payGateTranDate, serviceStatusCode=@serviceStatusCode WHERE refId=@refId"),
      parameters: {
        'rrn': model.rrn,
        'payGateTranID': model.payGateTranID,
        'amount': model.amount,
        'cardNumber': model.cardNumber,
        'payGateTranDate': model.payGateTranDate,
        'serviceStatusCode': model.serviceStatusCode,
        'refId': refId
      },
    );
  }
}
