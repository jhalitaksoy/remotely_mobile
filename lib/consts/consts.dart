import 'package:flutter/material.dart';
import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/views/room_page.dart';

class Routes {
  static const LoginRegisterRoute = "login_register";
  static const HomeRoute = "home";
  static const RoomRoute = "room";
  static const LoadingRoute = "loading";

  static void navigateRoompage(BuildContext context, int roomID) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoomPage(roomID),
      ),
    );
  }
}
