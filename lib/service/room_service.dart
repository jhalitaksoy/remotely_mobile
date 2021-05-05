import 'dart:convert';
import 'dart:io';

import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/service/service.dart';

class RoomServiceImpl extends RoomService {
  final createRoomRoute = "room/create";
  final listRoomsRoute = "room/listRooms";

  RoomServiceImpl(HttpService httpService) : super(httpService);

  @override
  Future<bool> createRoom(Room room) async {
    try {
      final response = await httpService.post(createRoomRoute, room.toJson());
      if (response.statusCode < 400) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        Future.error("Internet connection problem!");
      }
      return Future.error("Internal Error : " + e.toString());
    }
  }

  @override
  Future<List<Room>> listRooms() async {
    final list = List<Room>();
    try {
      final response = await httpService.post(listRoomsRoute, {});
      if (response.statusCode < 400) {
        final json = jsonDecode(response.body);
        if (json is List) {
          for (var roomJson in json) {
            final room = Room.fromJson(roomJson);
            list.add(room);
          }
        }
        return list;
      } else {
        return Future.error(
            "Internal Error : Status Code" + response.statusCode.toString());
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        Future.error("Internet connection problem!");
      }
      return Future.error("Internal Error : " + e.toString());
    }
  }
}
