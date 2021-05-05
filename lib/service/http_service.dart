import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:remotely_mobile/service/service.dart';

class HttpServiceImpl extends HttpService {
  Future<Map<String, String>> Function() onCreateHeaders;
  Uri Function(String route) onCreateUrl;
  Function(http.Response) onUnauthorized;

  HttpServiceImpl(
    this.onCreateHeaders,
    this.onCreateUrl,
    this.onUnauthorized,
  );

  Future<http.Response> post(
    String route,
    Map<String, dynamic> bodyData,
  ) async {
    assert(onCreateHeaders != null);
    assert(onCreateUrl != null);
    assert(route != null);
    assert(route.isNotEmpty);
    assert(bodyData != null);

    try {
      final headers = await onCreateHeaders();
      final response = await http.post(
        onCreateUrl(route),
        headers: headers,
        body: jsonEncode(bodyData),
      );
      if (response.statusCode == 401) {
        onUnauthorized(response);
      }
      return response;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }
}
