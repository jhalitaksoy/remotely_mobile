import 'package:flutter_test/flutter_test.dart';
import 'package:remotely_mobile/service/http_service.dart';

void main() {
  test("Http Post Test ", () async {
    const endPoint = "localhost:8080";
    final httpService = new HttpServiceImpl(
      () {
        return Future.value(<String, String>{});
      },
      (route) {
        return Uri.http(endPoint, route);
      },
      (response) {
        print("unauth");
      },
    );

    final response = await httpService.post("route", {"test": "test"});
    print(response.statusCode);
  });
}
