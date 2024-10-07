import 'models/service_model.dart';

abstract interface class DatabaseRepository<T>{
  Future<void> write(T model);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<void> update(String id, T model);
  Future<void> delete(String id);
}

class ServiceRepository implements DatabaseRepository<ServiceModel>{
  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<ServiceModel>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<ServiceModel?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<void> update(String id, ServiceModel model) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<void> write(ServiceModel model) {
    // TODO: implement write
    throw UnimplementedError();
  }
}