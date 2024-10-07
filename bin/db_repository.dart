import 'package:postgres/postgres.dart';

import 'models/service_model.dart';

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
  static ServiceRepository? _instance;
  ServiceRepository._internal(this.connection);

  factory ServiceRepository(Connection connection) {
    return _instance ??= ServiceRepository._internal(connection);
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
}
