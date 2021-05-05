abstract class Storeage {
  void write(String key, String value);
  Future<String> read(String key, String _default);
  void delete(String key);
}

abstract class Store<T> {
  Storeage storeage;

  Store(this.storeage);

  Future<T> get();
  void set(T t);
  void delete();
}
