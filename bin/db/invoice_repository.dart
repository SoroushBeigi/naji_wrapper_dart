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

  @override
  Future<InvoiceData?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> update(String id, InvoiceData model) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
