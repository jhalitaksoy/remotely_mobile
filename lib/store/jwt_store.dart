import 'package:remotely_mobile/store/store.dart';

class JWTStore extends Store<String> {
  final String key = "jwt";

  JWTStore(Storeage storeage) : super(storeage);

  @override
  void delete() {
    return storeage.delete(key);
  }

  @override
  Future<String> get() {
    return storeage.read(key, null);
  }

  @override
  void set(String value) {
    return storeage.write(key, value);
  }
}
