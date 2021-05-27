import 'package:http/http.dart';
import 'package:remotely_mobile/rtmt/rtmt.dart';
import 'package:remotely_mobile/rtmt/rtmt_datachannel.dart';
import 'package:remotely_mobile/rtmt/rtmt_websocket.dart';
import 'package:remotely_mobile/service/auth_service.dart';
import 'package:remotely_mobile/service/http_service.dart';
import 'package:remotely_mobile/service/room_service.dart';
import 'package:remotely_mobile/service/service.dart';
import 'package:remotely_mobile/store/jwt_store.dart';
import 'package:remotely_mobile/store/mem_storeage.dart';
import 'package:remotely_mobile/store/persistent_storeage.dart';
import 'package:remotely_mobile/store/store.dart';

const wsUrl = "ws://10.0.2.2:8080" + "/room/ws/";
const endpoint = "10.0.2.2:8080";
//const endpoint = "192.168.43.2:8080";

class Context {
  Store jwtStore;
  AuthService authService;
  bool hasJwtKey = false;
  RoomService roomService;
  RealtimeMessageTransport rtmt;
  HttpService httpService;
  Context(this.httpService, this.jwtStore, this.authService, this.hasJwtKey,
      this.roomService, this.rtmt);
}

Context createTestContext() {
  final memStoreage = MemStoreage();
  final jwtStore = JWTStore(memStoreage);
  final httpService = HttpServiceImpl(
    () => Future.value({}),
    (route) => Uri.http(endpoint, route),
    (response) => print("Unauth"),
  );

  final authService = AuthServiceImpl(httpService, jwtStore);
  final roomService = RoomServiceImpl(httpService);
  final rtmt = RealtimeMessageTransportDataChannel();

  return Context(httpService, jwtStore, authService, false, roomService, rtmt);
}

Future<Context> createContext(Function(Response) onUnauthorized) async {
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
  final rtmt = RealtimeMessageTransportWS(wsUrl);
  return Context(
      httpService, jwtStore, authService, jwt != null, roomService, rtmt);
}
