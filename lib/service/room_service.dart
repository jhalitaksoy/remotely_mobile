import 'dart:convert';
import 'dart:io';

import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/models/room_chat.dart';
import 'package:remotely_mobile/service/service.dart';

class RoomServiceImpl extends RoomService {
  final createRoomRoute = "room/create";
  final listRoomsRoute = "room/listRooms";
  final getRoomRoute = "room/get";
  final chatRoute = "room/chat";

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
    final list = <Room>[];
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

  @override
  Future<Room> getRoomById(int id) async {
    try {
      final response =
          await httpService.post(getRoomRoute + "/" + id.toString(), {});
      if (response.statusCode < 400) {
        final json = jsonDecode(response.body);
        final room = Room.fromJson(json);
        return room;
      } else {
        //todo check 404
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

  @override
  Future<List<ChatMessage>> getRoomChatMessagesById(int id) async {
    List<ChatMessage> messages = [];
    try {
      final response =
          await httpService.post(chatRoute + "/" + id.toString(), {});
      if (response.statusCode < 400) {
        final json = jsonDecode(response.body);
        if (json is List) {
          for (var chatMessageJson in json) {
            final chatMessage = ChatMessage.fromJson(chatMessageJson);
            messages.add(chatMessage);
          }
        }
        return messages;
      } else {
        //todo check 404
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
