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