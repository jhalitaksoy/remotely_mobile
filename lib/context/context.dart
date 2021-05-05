import 'package:http/http.dart';
import 'package:remotely_mobile/service/auth_service.dart';
import 'package:remotely_mobile/service/http_service.dart';
import 'package:remotely_mobile/service/room_service.dart';
import 'package:remotely_mobile/service/service.dart';
import 'package:remotely_mobile/store/jwt_store.dart';
import 'package:remotely_mobile/store/mem_storeage.dart';
import 'package:remotely_mobile/store/persistent_storeage.dart';
import 'package:remotely_mobile/store/store.dart';

class Context {
  Store jwtStore;
  AuthService authService;
  bool hasJwtKey = false;
  RoomService roomService;
  Context(this.jwtStore, this.authService, this.hasJwtKey, this.roomService);
}

Context createTestContext() {
  const endpoint = "localhost:8080";
  final memStoreage = MemStoreage();
  final jwtStore = JWTStore(memStoreage);
  final httpService = HttpServiceImpl(
    () => Future.value({}),
    (route) => Uri.http(endpoint, route),
    (response) => print("Unauth"),
  );

  final authService = AuthServiceImpl(httpService, jwtStore);
  final roomService = RoomServiceImpl(httpService);
  return Context(jwtStore, authService, false, roomService);
}

Future<Context> createContext(Function(Response) onUnauthorized) async {
  const endpoint = "10.0.2.2:8080";
  final persistentStoreage = PersistentStoreage();
  final jwtStore = JWTStore(persistentStoreage);
  final jwt = await jwtStore.get();
  final httpService = HttpServiceImpl(
    () async {
      final jwt = await jwtStore.get();
      if (jwt == null) {
        return Future.value({});
      }

      return {
        'Authorization': "Bearer " + jwt,
      };
    },
    (route) => Uri.http(endpoint, route),
    onUnauthorized,
  );

  final authService = AuthServiceImpl(httpService, jwtStore);
  final roomService = RoomServiceImpl(httpService);
  return Context(jwtStore, authService, jwt != null, roomService);
}
