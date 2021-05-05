import 'package:http/http.dart';
import 'package:remotely_mobile/models/auth.dart';
import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/store/store.dart';

abstract class HttpService {
  Future<Response> post(String route, Map<String, dynamic> bodyData);
}

abstract class AuthService {
  HttpService httpService;
  Store jwtStore;

  AuthService(this.httpService, this.jwtStore);

  Future<bool> register(RegisterParameters registerParameters);
  Future<bool> login(LoginParameters loginParameters);
}

abstract class RoomService {
  HttpService httpService;
  RoomService(this.httpService);

  Future<bool> createRoom(Room room);

  Future<List<Room>> listRooms();
}
