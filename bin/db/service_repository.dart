import 'package:postgres/postgres.dart';

import '../models/service_model.dart';
import 'db_mixins.dart';

class ServiceRepository
    with
        Readable<ServiceModel>,
        Updatable<ServiceModel>,
        Deletable,
        Writable<ServiceModel> {
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
  Future<List<ServiceModel>?> getAll() async {
    final result = await connection
        .execute("SELECT * FROM services WHERE isDeleted=false");
    if(result.isEmpty){
      return null;
    }
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
  Future<ServiceModel?> getById(String id) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM services WHERE id=@id AND isDeleted=false"),
      parameters: {'id': id},
    );
    if(result.isEmpty){
      return null;
    }
    return ServiceModel(
      id: result[0][0].toString(),
      serviceName: result[0][1].toString(),
      price: result[0][2].toString(),
      title: result[0][3].toString(),
      inputs: result[0][4].toString(),
    );
  }

  Future<int> getPrice(String id) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM services WHERE id=@id"),
      parameters: {'id': id},
    );
    return int.parse(result[0][2].toString());
  }

  @override
  Future<void> delete(String id) async {
    final result = await connection.execute(
      Sql.named("UPDATE services SET isDeleted=true WHERE id=@id"),
      parameters: {'id': id},
    );
  }

  @override
  Future<void> update(String id, ServiceModel model) async {
    final result = await connection.execute(
      Sql.named(
          "UPDATE services SET serviceName=@serviceName, price=@price, title=@title,inputs=@inputs WHERE id=@id"),
      parameters: {
        'serviceName': model.serviceName,
        'price': model.price,
        'title': model.title,
        'inputs': model.inputs,
        'id': id
      },
    );
  }

  @override
  Future<void> write(ServiceModel model) async {
    final result = await connection.execute(
      Sql.named(
          "INSERT INTO services (serviceName, price, title, inputs) VALUES (@serviceName, @price, @title, @inputs)"),
      parameters: {
        'serviceName': model.serviceName,
        'price': model.price,
        'title': model.title,
        'inputs': model.inputs
      },
    );
  }
}

