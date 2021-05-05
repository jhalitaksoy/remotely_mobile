import 'package:flutter_test/flutter_test.dart';
import 'package:remotely_mobile/models/auth.dart';
import 'package:remotely_mobile/service/auth_service.dart';
import 'package:remotely_mobile/service/http_service.dart';
import 'package:remotely_mobile/service/service.dart';
import 'package:remotely_mobile/store/jwt_store.dart';
import 'package:remotely_mobile/store/mem_storeage.dart';
import 'package:remotely_mobile/store/store.dart';

void main() {
  test('Auth Service Test', () async {
    const endPoint = "localhost:8080";
    HttpService httpService = new HttpServiceImpl(
      () => Future.value(<String, String>{}),
      (route) => Uri.http(endPoint, route),
      (response) => print("unauth"),
    );

    Store jwtStore = new JWTStore(new MemStoreage());

    AuthService authService = new AuthServiceImpl(httpService, jwtStore);

    /*final registerParameters = RegisterParameters(
      name: "hlt_test",
      password: "1234",
    );
    final isRegisterSucces = await authService.register(registerParameters);
    assert(isRegisterSucces);*/

    final loginParameters = LoginParameters(
      name: "hlt_test",
      password: "1234",
    );
    final isLoginSucces = await authService.login(loginParameters);
    assert(isLoginSucces);

    final jwtKey = jwtStore.get();
    print(jwtKey);
  });
}
