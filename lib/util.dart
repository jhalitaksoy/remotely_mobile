import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

Future<RTCSessionDescription> getRemoteSdp(RTCSessionDescription sd) async {
  final String user_id = "0";
  final String room_id = "0";

  final body = {
    "sd": {
      "type": sd.type,
      "sdp": sd.sdp,
    },
    "name": "Client"
  };

  var url = 'http://10.0.2.2/stream/sdp/' + room_id;
  var response = await http
      .post(url, body: json.encode(body), headers: {'userID': user_id});
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  //print(await http.read('https://example.com/foobar.txt'));
  final map = json.decode(response.body);
  final _sd = map["SD"];
  return RTCSessionDescription(_sd["sdp"] as String, _sd["type"] as String);
}
