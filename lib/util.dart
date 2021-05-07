import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/main.dart';

Future<RTCSessionDescription> getRemoteSdp(
    String roomID, RTCSessionDescription sd) async {
  final body = {
    "sd": {
      "type": sd.type,
      "sdp": sd.sdp,
    },
    "name": "Client"
  };

  var url = 'stream_private/sdp/' + roomID;
  var response = await myContext.httpService.post(url, body);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  final map = json.decode(response.body);
  final _sd = map["SD"];
  return RTCSessionDescription(_sd["sdp"] as String, _sd["type"] as String);
}
