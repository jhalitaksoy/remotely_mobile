import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/main.dart';

//todo : refactor
Future<RTCSessionDescription> getRemoteSdp(
  String roomID,
  RTCSessionDescription sd,
) async {
  final body = {
    "sd": {
      "type": sd.type,
      "sdp": sd.sdp,
    },
    "name": "Client"
  };
  var route = 'stream_private/sdp/' + roomID;
  try {
    final response = await myContext.httpService.post(route, body);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final map = json.decode(response.body);
    final _sd = map["SD"];
    return RTCSessionDescription(_sd["sdp"] as String, _sd["type"] as String);
  } catch (e) {
    print(e);
    return Future.error(e);
  }
}
