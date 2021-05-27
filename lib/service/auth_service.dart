import 'dart:convert';
import 'dart:io';

import 'package:remotely_mobile/models/auth.dart';
import 'package:remotely_mobile/service/service.dart';
import 'package:remotely_mobile/store/store.dart';

class AuthServiceImpl extends AuthService {
  final String registerRoute = "user/register";
  final String loginRoute = "user/login";

  AuthServiceImpl(HttpService httpService, Store jwtStore)
      : super(httpService, jwtStore);

  @override
  Future<bool> login(LoginParameters loginParameters) async {
    jwtStore.delete();
    try {
      final response =
          await httpService.post(loginRoute, loginParameters.toJson());
      if (response.statusCode < 400) {
        final loginResult = LoginResult.fromJson(jsonDecode(response.body));
        jwtStore.set(loginResult.jwtToken);
        return true;
      } else if (response.statusCode == 409) {
        return false;
      } else {
        return Future.error("Internal Error");
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        return Future.error("Internet Connection Problem");
      }
      return Future.error("Internal Error");
    }
  }

  @override
  Future<bool> register(RegisterParameters loginParameters) async {
    try {
      final response =
          await httpService.post(registerRoute, loginParameters.toJson());
      if (response.statusCode < 400) {
        return true;
      } else if (response.statusCode == 409) {
        return false;
      } else {
        return Future.error("Internal Error");
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        return Future.error("Internet Connection Problem");
      }
      return Future.error("Internal Error");
    }
  }
}
