import 'package:postgres/postgres.dart';

import 'models/service_model.dart';
import 'models/invoice_model.dart';

mixin Writable<T> {
  Future<void> write(T model);
}

mixin Readable<T> {
  Future<T?> getById(String id);

  Future<List<T>> getAll();
}

mixin Updatable<T> {
  Future<void> update(String id, T model);
}

mixin Deletable {
  Future<void> delete(String id);
}

class ServiceRepository with Readable<ServiceModel> {
  static ServiceRepository? instance;

  ServiceRepository._internal(this.connection);

  factory ServiceRepository(Connection connection) {
    return instance ??= ServiceRepository._internal(connection);
  }

  void init() {
    instance = ServiceRepository._internal(connection);
  }

  final Connection connection;

  @override
  Future<List<ServiceModel>> getAll() async {
    final result = await connection.execute("SELECT * FROM services");
    return result
        .map(
          (element) => ServiceModel(
            id: element[0].toString(),
            serviceName: element[1].toString(),
            price: element[2].toString(),
            title: element[3].toString(),
            inputs: element[4].toString(),
          ),
        )
        .toList();
  }

  @override
  Future<ServiceModel?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  Future<int> getPrice(String id) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM services WHERE id=@id"),
      parameters: {'id': id},
    );
    return int.parse(result[0][2].toString());
  }
}

class InvoiceRepository with Readable<InvoiceData>, Writable<InvoiceData> {
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
  Future<void> write(invoiceData)async {
    //TODO: finish writing db logic!!
    String keys = '';
    String values = '';
    invoiceData.getFields().forEach((key, value) {
      keys+= "$key, ";
      values+= "'$value', ";
    });
    String query = 'INSERT INTO invoices (';
    final result = await connection.execute(
      Sql.named('UPDATE invoices SET'),
      parameters: {'id': 'xyz'},
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
}
