import 'package:remotely_mobile/store/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistentStoreage extends Storeage {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void delete(String key) async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(key);
  }

  @override
  Future<String> read(String key, String _default) async {
    final SharedPreferences prefs = await _prefs;
    var value = prefs.getString(key);
    if (value == null) {
      value = _default;
    }
    return value;
  }

  @override
  void write(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(key, value);
  }
}
