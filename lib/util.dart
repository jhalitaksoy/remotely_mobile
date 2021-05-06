import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:remotely_mobile/main.dart';

Future<RTCSessionDescription> getRemoteSdp(
    String roomID, RTCSessionDescription sd) async {
  final String room_id = "10";

  final body = {
    "sd": {
      "type": sd.type,
      "sdp": sd.sdp,
    },
    "name": "Client"
  };

  var url = 'stream_private/sdp/' + room_id;
  var response = await myContext.httpService.post(url, body);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  //print(await http.read('https://example.com/foobar.txt'));
  final map = json.decode(response.body);
  final _sd = map["SD"];
  return RTCSessionDescription(_sd["sdp"] as String, _sd["type"] as String);
}
