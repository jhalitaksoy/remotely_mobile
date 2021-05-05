import 'package:remotely_mobile/store/store.dart';

class MemStoreage extends Storeage {
  Map<String, dynamic> map = <String, dynamic>{};
  @override
  void delete(String key) {
    map.remove(key);
  }

  @override
  Future<String> read(String key, String _default) {
    var value = map[key];
    if (value == null) {
      value = _default;
    }
    return value;
  }

  @override
  void write(String key, String value) {
    map[key] = value;
  }
}
